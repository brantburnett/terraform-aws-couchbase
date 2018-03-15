#!/bin/bash -ex

${apply_updates}
yum install -y jq


### Setup time synchronization using Amazon Time Sync Service

yum erase -y ntp*
yum install -y chrony
service chronyd start


### Disable hugepages

tee /etc/init.d/disable-thp << EOL
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-thp
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    couchbase-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable THP
# Description:       disables Transparent Huge Pages (THP) on boot
### END INIT INFO
          
case $$$$1 in
start)
  if [ -d /sys/kernel/mm/transparent_hugepage ]; then
    echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
    echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
  elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
    echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/enabled
    echo 'never' > /sys/kernel/mm/redhat_transparent_hugepage/defrag
  else
    return 0
  fi
;;
esac
EOL

chmod 755 /etc/init.d/disable-thp
service disable-thp start
chkconfig disable-thp on


### Disable swapping

sysctl vm.swappiness=0
echo "vm.swappiness = 0" >> /etc/sysctl.conf


### Install Couchbase

echo "Installing Couchbase..."
wget -O ~/couchbase.rpm ${installer_url}
rpm -i ~/couchbase.rpm


### Mount data drive

echo "Formatting data drive..."
DEVICE=/dev/xvdb
DATADIR=/mnt/data

mkfs -t ext4 $$DEVICE

mkdir $$DATADIR
echo -e "$$DEVICE\t$$DATADIR\text4\tdefaults,nofail\t0\t2" >> /etc/fstab
mount -a

chown couchbase $$DATADIR
chgrp couchbase $$DATADIR


### Node init

sleep 15 # Give Couchbase some time to startup

instanceID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
echo "Instance ID: $$instanceID"

if [ "${topology}" == "private" ]; then
  nodeDNS=`curl -s http://169.254.169.254/latest/meta-data/local-hostname`
else
  nodeDNS=`curl -s http://169.254.169.254/latest/meta-data/public-hostname`
fi
echo "Node hostname: $$nodeDNS"

tempPassword=$$instanceID

while true
do
  echo "Initializing node..."
  /opt/couchbase/bin/couchbase-cli node-init \
    --cluster $$nodeDNS \
    --node-init-data-path $$DATADIR/data \
    --node-init-index-path $$DATADIR/index \
    --node-init-hostname $$nodeDNS \
    --user Administrator \
    --password $$tempPassword \
    && break

  echo "Sleeping 10 seconds before retry..."
  sleep 10
done


### Bootstrap

rallyAutoscalingGroup="${rally_autoscaling_group_id}"
if [[ -z $$rallyAutoscalingGroup ]]; then
  # We're in the rally autoscaling group, so get it from our tags

  echo "Getting autoscaling group name from tags..."
  rallyAutoscalingGroup=$(aws ec2 describe-instances \
    --region ${region} \
    --instance-ids $$instanceID \
    | jq '.Reservations[0].Instances[0].Tags[] | select( .Key == "aws:autoscaling:groupName") | .Value' \
    | sed 's/"//g')

  if [[ -z $$rallyAutoscalingGroup ]]; then
    echo "No rally autoscaling group found." 1>&2
    exit 1
  fi
fi

echo "Getting instances from the rally autoscaling group ($$rallyAutoscalingGroup)..."
rallyAutoscalingGroupInstanceIDs=$(aws autoscaling describe-auto-scaling-groups \
  --region ${region} \
  --query 'AutoScalingGroups[*].Instances[*].InstanceId' \
  --auto-scaling-group-name $$rallyAutoscalingGroup \
  | grep "i-" | sed 's/[ ",]//g' | sort)

rallyInstanceID=`echo $$rallyAutoscalingGroupInstanceIDs | cut -d " " -f1`

# Check if any IDs are already the rally point and overwrite rallyInstanceID if so
rallyAutoscalingGroupInstanceIDsArray=(`echo $$rallyAutoscalingGroupInstanceIDs`)
for i in $${rallyAutoscalingGroupInstanceIDsArray[@]}; do
  tags=`aws ec2 describe-tags --region ${region} --filter "Name=tag:Rally,Values=1" "Name=resource-id,Values=$$i"`
  tags=`echo $tags | jq '.Tags'`
  if [ "$tags" != "[]" ]
  then
    rallyInstanceID=$i
  fi
done

echo "Rally Instance ID: $$rallyInstanceID"

if [ "${topology}" == "private" ]; then
  rallyDNS=$(aws ec2 describe-instances \
    --region ${region} \
    --query 'Reservations[0].Instances[0].PrivateDnsName' \
    --instance-ids $$rallyInstanceID \
    --output text)
else
  rallyDNS=$(aws ec2 describe-instances \
    --region ${region} \
    --query 'Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName' \
    --instance-ids $$rallyInstanceID \
    --output text)
fi

echo "Rally DNS: $$rallyDNS"

if [ "$$rallyDNS" == "$$nodeDNS" ]; then
  echo "This is the rally server, setting tags..."

  aws ec2 create-tags \
    --region ${region} \
    --resources $$instanceID \
    --tags Key=Rally,Value=1

  # use env vars because -u and -p are deprecated in 5.0, this makes us compatible with older versions too
  CB_REST_USERNAME=Administrator
  CB_REST_PASSWORD=$$tempPassword

  echo "Initializing cluster..."

  /opt/couchbase/bin/couchbase-cli cluster-init \
    --cluster $$rallyDNS \
    --cluster-username=${cluster_admin_username} --cluster-password=${cluster_admin_password} \
    --cluster-ramsize=${data_ramsize} --cluster-index-ramsize=${index_ramsize} --cluster-fts-ramsize=${fts_ramsize} \
    --index-storage-setting=${index_storage} --services=${services} ${cluster_name_init == "" ? "" : "--cluster-name \"${cluster_name_init}\""}

  if [ "${couchbase_edition}" == "enterprise" ]; then
    availabilityZone=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
      
    echo "Setting initial server group name to $$availabilityZone..."
    curl -s -X PUT -u ${cluster_admin_username}:${cluster_admin_password} \
      http://$$rallyDNS:8091/pools/default/serverGroups/0 \
      -d name="$$availabilityZone"
  fi
else
  echo "Using rally server $$rallyDNS, setting tags..."

  aws ec2 create-tags \
    --region ${region} \
    --resources $$instanceID \
    --tags Key=Rally,Value=0

  # Manage Server Groups For Rack Zone Awareness, if Enterprise Edition

  if [ "${couchbase_edition}" == "enterprise" ]; then
    while true
    do
      echo "Checking server groups..."
      
      availabilityZone=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
      matchingGroupCount=`curl -s -u ${cluster_admin_username}:${cluster_admin_password} http://$$rallyDNS:8091/pools/default/serverGroups \
        | jq -r '.groups[].name' \
        | sed -n "/$$availabilityZone/p" \
        | wc -l`

      if [ "$$matchingGroupCount" == "0" ]; then
        echo "Creating Server Group $$availabilityZone..."

        curl -s -X POST -u ${cluster_admin_username}:${cluster_admin_password} \
          http://$$rallyDNS:8091/pools/default/serverGroups \
          -d name="$$availabilityZone" \
          && break

        echo "Sleeping 10 seconds before retry..."
        sleep 10
      else
        echo "Server Group $$availabilityZone exists."
        break
      fi
    done

    addGroupName="--group-name=$$availabilityZone"
  fi

  while true
  do
    echo "Adding node to cluster via $$rallyDNS..."

    /opt/couchbase/bin/couchbase-cli server-add \
      --cluster $$rallyDNS \
      --username ${cluster_admin_username} \
      --password ${cluster_admin_password} \
      --server-add=$$nodeDNS:8091 \
      --server-add-username=Administrator \
      --server-add-password=$$tempPassword \
      --services=${services} \
      $$addGroupName \
      && break

    echo "Sleeping 10 seconds before retry..."
    sleep 10
  done
fi

# Provide credentials for additional scripts to use
CB_REST_USERNAME=${cluster_admin_username}
CB_REST_PASSWORD=${cluster_admin_password}


# Rebalance, if enabled

if [ "${auto_rebalance ? "true" : "false"}" == "true" ]; then
  while true
  do
    echo "Running Couchbase rebalance..."

    /opt/couchbase/bin/couchbase-cli rebalance \
      --cluster=$$rallyDNS \
      --user=$$CB_REST_USERNAME \
      --pass=$$CB_REST_PASSWORD \
      && break

    echo "Sleeping 10 seconds before retry..."
    sleep 10
  done
fi

${additional_initialization_script}
