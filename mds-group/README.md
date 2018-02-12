# terraform-aws-couchbase/mds-group

Terraform module for creating a group of Couchbase nodes on AWS using Amazon Linux

## How To Use

The scripts may be referenced using Terraform Modules.  For details on modules, see [the Terraform documentation](https://www.terraform.io/docs/modules/usage.html).  The module may be referenced directly from GitHub, or you can make a local copy into a subfolder.

For a variable reference, see the `variables.tf` file.

## Rally MDS Group

When creating a cluster, you should create one MDS group which is the rally group.  The first node in this group is selected automatically as the rally node.  This node is used to create the initial cluster, and all other nodes will join the cluster via this node.  After the cluster is bootstrapped, this node is no different from other nodes in the cluster.

For the rally MDS group, leave the `rally_autoscaling_group_id` variable empty, which causes the module to treat this group as the rally group.  Also, you will probably want to specify cluster settings such as `cluster_ram_size` and `cluster_index_storage`.

## Additional MDS Groups

All other groups in the cluster should have the `rally_autoscaling_group_id` supplied.  The rally node from this auto scaling group will be used for bootstrapping the nodes.