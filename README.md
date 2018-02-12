# terraform-aws-couchbase

Terraform module for creating a Couchbase cluster.

## How To Use

The scripts may be referenced using Terraform Modules.  For details on modules, see [the Terraform documentation](https://www.terraform.io/docs/modules/usage.html).  The module may be referenced directly from GitHub, or you can make a local copy into a subfolder.

For a variable reference, see the `variables.tf` file.

## Example

There is an example available in the [example folder](./example).

## Multidimensional Scaling Groups

Please see the [Couchbase Documentation on Multidimensional Scaling](https://developer.couchbase.com/documentation/server/current/architecture/services-archi-multi-dimensional-scaling.html) for more information on the concept.

Up to five MDS groups can be defined.  Each MDS group may run different services, have different node types, etc.  Information about each MDS group is supplied via map variables, with the groups numbered 1 through 5.

Only MDS groups with a node_count greater than 0 are created.  Each MDS group must also have a unique name.

```terraform
node_count = {
    "1" = 2
    "2" = 1
    "3" = 1
}

group_name = {
    "1" = "Data"
    "2" = "Index"
    "3" = "Query"
}

# It is valid to include more than one service in a single MDS group
# However, the first MDS group should at least include the data service
# Note: If you use Community Edition, you must use a single MDS group with all services.

services = {
    "1" = ["data"]
    "2" = ["index"]
    "3" = ["query"]
}
```

For most other MDS group settings, such as `instance_type`, if you set the value for group "1" it will be automatically used for all other groups unless expressly overridden.

## AMI

This module requires the use of an Amazon Linux AMI.  By default, the latest Amazon-provided AMI is used automatically.  However, you may supply the `ami` variable to override this behavior and use a custom AMI, so long as it is still based on Amazon Linux.

## Data Volume

To control the size and type of your data volume, supply a data volume setting via `data_volume`.  This setting is per MDS group, but the value for group 1 will be the default for all other groups.

```terraform
data_volume = {
    "1" = {
        volume_type = "gp2" # SSD
        volume_size = "100" # Size is in GB
    }
}
```

You may supply any settings available for an [ebs_block_device](https://www.terraform.io/docs/providers/aws/r/instance.html), except for device_name.

Note that this setting only takes effect for new clusters and newly launched nodes, not existing nodes.

## Security Groups

Security groups are created automatically to enable inter-node communication within the cluster and communication from clients.  Access is granted for clients by including values in the `client_security_group_ids` and/or `client_cidr_blocks` list variables.

To grant other kinds of access, such as SSH or XDCR, you may attach additional security groups using `security_group_ids`.  Note that this change only takes effect on newly launched nodes/clusters, it will not affect existing nodes.

## IAM Instance Profile

To support bootstrapping via the a rally node, the EC2 instances need the following security rights applied via an IAM role:

- ec2:CreateTags
- ec2:DescribeTags
- ec2:DescribeInstances
- autoscaling:DescribeAutoScalingGroups

By default, an IAM role and IAM instance profile are created for this purpose.  If this is not an option in your environment for security reasons, you may supply your own profile via "iam_instance_profile".

## Additional Initialization Script

You may provide some additional Bash script content to run on startup via `additional_initialization_script`.  This runs after the node is fully initialized and joined to the cluster, and is useful for installing things like monitoring tools.

## Auto Rebalancing

Auto rebalancing is enabled by default.  This is useful for development and new clusters, but may not be desired for large production clusters.  You may launch a new cluster with auto_rebalance enabled, then disable it and rerun terraform apply.  This will disable auto rebalance for future node adds.

## Upgrading Your Cluster using a [Swap Rebalance](https://developer.couchbase.com/documentation/server/current/install/upgrade-online.html)

1.  Set `auto_rebalance` to false and set the new `couchbase_version`.
2.  Increase the size of your cluster by one node.
3.  Run `terraform apply` to apply the changes.
4.  Wait for the new node to join the cluster.
5.  In the Couchbase Web UI, remove one node with the same services.  You should now have one node Pending Add and a matching node Pending Removal.
6.  Run a rebalance, and wait for it to complete.
7.  Terminate the EC2 instance you removed, which will cause the Auto Scaling Group to launch a replacement.
8.  Repeat steps 5-7 one node at a time until all nodes have been swapped.
9.  Use the AWS Console or CLI to remove the final leftover node from the Auto Scaling Group while *decreasing* the desired capacity.
10. Terminate the leftover node