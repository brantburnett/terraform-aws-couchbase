variable "name" {
	description = "Name of the autoscaling group and EC2 instances."
}

variable "node_count" {
	description = "Number of nodes to create"
	default = 1
}

variable "tags" {
	description = "Tags for the autoscaling group and EC2 instances.  This is a list of maps with `key`, `value`, and `propogate_at_launch` entries."
	default = []
}

variable "services" {
	description = "List of node services (data, index, query, fts)"
	default = ["data", "index", "query", "fts"]
}

variable "cluster_name" {
	description = "Cluster name for bootstrapping, only used by the rally node"
}

variable "cluster_admin_username" {
	description = "Cluster administrator user name for bootstrapping"
	default = "Administrator"
}

variable "cluster_admin_password" {
	description = "Cluster administrator password for bootstrapping"
}

variable "cluster_index_storage" {
	description = "Index storage method for the cluster, used only on the rally node (i.e. `default` or `memopt`"
	default = "default"
}

variable "cluster_ram_size" {
	description = "RAM size in MB for the each service, used only on the rally node"

	default = {
		data = 10000
		index = 10000
		fts = 10000
	}
}

variable "analytics_mpp" {
    type        = "list"
    description = "List of names for each analytics data folder for MPP.  Should normally match the number of cores."

    default = [
        "0",
        "1",
    ]
}

variable "installer_url" {
	description = "URL for installer to download and install on each instance, uses default if blank"
	default = ""
}

variable "couchbase_version" {
	type = "string"
	description = "If installer_url is blank, use this version of Couchbase"
}

variable "couchbase_edition" {
	description = "If installer_url is blank, use this edition of Couchbase ('enterprise' or 'community')"
	default = "community"
}

variable "rally_autoscaling_group_id" {
	description = "ID of the rally auto scaling group.  If blank, this is the rally MDS group."
	default = ""
}

variable "auto_rebalance" {
	description = "If true, automatically performs a rebalance as soon as nodes are added to the cluster.  This may not be desirable in large production clusters."
	default = true
}

variable "instance_type" {
	description = "Instance type, such as 'm4.xlarge'"
	default = "m4.xlarge"
}

variable "key_pair_name" {
	description = "EC2 key pair for creating the instance"
}

variable "ami" {
	description = "ID of the AMI to use, or blank to auto select"
	default = ""
}

variable "apply_updates" {
	description = "If true, yum updates are applied during the first boot"
	default = true
}

variable "subnet_ids" {
	type = "list"
	description = "List of subnets the nodes will be created within"
}

variable "security_group_ids" {  
	type = "list"
	description = "List of security groups to assign"
}

variable "topology" {  
	description = "Indicates if the cluster is using public or private hostnames.  Must be either 'public' or 'private'."
	default = "private"
}

variable "iam_instance_profile" {
	description = "IAM instance profile to apply IAM roles"
	default = ""
}

variable "termination_protection" {
	description = "If true, prevents accidental termination"
	default = false
}

variable "detailed_monitoring" {
	description = "If true, turns on detailed CloudWatch monitoring (additional cost)"
	default = false
}

variable "placement_tenancy" {
	description = "Indicates instance host tenancy, 'default' or 'dedicated'"
	default = "default"
}

variable "boot_volume" {
	description = "Configuration of the boot volume"
	default = {
		volume_type = "gp2"
		volume_size = "30"
	}
}

variable "data_volume" {
	description = "Configuration of the data volume"
	default = {
		volume_type = "gp2"
		volume_size = "300"
	}
}

variable "ebs_optimized" {
	description = "If true, create an EBS optimized instance"
	default = true
}

variable "additional_initialization_script" {
	description = "Additional Bash script to run after the node is initialized"
	default = ""
}