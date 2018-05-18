variable "cluster_name" {
	description = "Cluster name, only used when bootstrapping a new cluster"
}

variable "cluster_admin_username" {
	description = "Cluster administrator user name for bootstrapping"
	default = "Administrator"
}

variable "cluster_admin_password" {
	description = "Cluster administrator password for bootstrapping"
}

variable "cluster_index_storage" {
	description = "Index storage method for the cluster, used only on the primary bootstrap node (i.e. `default` or `memopt`"
	default = "default"
}

variable "cluster_ram_size" {
	description = "RAM size in MB for the each service, used only on the primary bootstrap node"

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

variable "auto_rebalance" {
	description = "If true, automatically performs a rebalance as soon as nodes are added to the cluster.  This may not be desirable in large production clusters."
	default = true
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
	description = "List of additional security groups to assign.  This is in addition to the automatically created security groups."
	default = []
}

variable "topology" {  
	description = "Indicates if the cluster is using public or private hostnames.  Must be either 'public' or 'private'."
	default = "private"
}

variable "iam_instance_profile" {
	description = "IAM instance profile to apply IAM roles.  If missing, a new role will be created instead.  The profile must include certain rights, consult README.md."
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

variable "client_security_group_ids" {
	description = "List of security group IDs to receive client-to-node access"
	default = []
}

variable "client_cidr_blocks" {
	description = "List of CIDR blocks to receive client-to-node access"
	default = []
}

variable "group_name" {
	description = "Name of each MDS group"
	default = {}
}

variable "node_count" {
	description = "Default number of nodes for each MDS group"
	default = {
		"1" = 1
	}
}

variable "tags" {
	description = "Tags for each autoscaling group and EC2 instances.  Each MDS group has a list of maps with `key`, `value`, and `propogate_at_launch` entries."
	default = {
		"1" = []
	}
}

variable "services" {
	description = "List of node services (data, index, query, fts) for each MDS group"
	default = {
		"1" = ["data", "index", "query", "fts"]
	}
}

variable "instance_type" {
	description = "Instance type for each MDS group, such as 'm4.xlarge'"
	default = {
		"1" = "m4.xlarge"
	}
}

variable "data_volume" {
	description = "Configuration of the data volume for each MDS group"
	default = {
		"1" = {
			volume_type = "gp2"
			volume_size = "300"
		}
	}
}

variable "ebs_optimized" {
	description = "For each MDS group, creates an EBS optimized instance if true."
	default = {
		"1" = true
	}
}

variable "additional_initialization_script" {
	description = "Additional Bash script to run after the node is initialized for each MDS group."
	default = {
		"1" = ""
	}
}

locals {
	default_group_name = {
		"1" = "Main"
		"2" = "MDS Group 2"
		"3" = "MDS Group 3"
		"4" = "MDS Group 4"
		"5" = "MDS Group 5"
	}
	group_name = "${merge(local.default_group_name, var.group_name)}"

	default_node_count = {
		"2" = 0
		"3" = 0
		"4" = 0
		"5" = 0
	}
	node_count = "${merge(local.default_node_count, var.node_count)}"

	default_tags = {
		"2" = "${var.tags["1"]}"
		"3" = "${var.tags["1"]}"
		"4" = "${var.tags["1"]}"
		"5" = "${var.tags["1"]}"
	}
	tags = "${merge(local.default_tags, var.tags)}"

	default_services = {
		"2" = "${var.services["1"]}"
		"3" = "${var.services["1"]}"
		"4" = "${var.services["1"]}"
		"5" = "${var.services["1"]}"
	}
	services = "${merge(local.default_services, var.services)}"

	default_instance_type = {
		"2" = "${var.instance_type["1"]}"
		"3" = "${var.instance_type["1"]}"
		"4" = "${var.instance_type["1"]}"
		"5" = "${var.instance_type["1"]}"
	}
	instance_type = "${merge(local.default_instance_type, var.instance_type)}"

	default_data_volume = {
		"2" = "${var.data_volume["1"]}"
		"3" = "${var.data_volume["1"]}"
		"4" = "${var.data_volume["1"]}"
		"5" = "${var.data_volume["1"]}"
	}
	data_volume = "${merge(local.default_data_volume, var.data_volume)}"

	default_ebs_optimized = {
		"2" = "${var.ebs_optimized["1"]}"
		"3" = "${var.ebs_optimized["1"]}"
		"4" = "${var.ebs_optimized["1"]}"
		"5" = "${var.ebs_optimized["1"]}"
	}
	ebs_optimized = "${merge(local.default_ebs_optimized, var.ebs_optimized)}"

	default_additional_initialization_script = {
		"2" = "${var.additional_initialization_script["1"]}"
		"3" = "${var.additional_initialization_script["1"]}"
		"4" = "${var.additional_initialization_script["1"]}"
		"5" = "${var.additional_initialization_script["1"]}"
	}
	additional_initialization_script = "${merge(local.default_additional_initialization_script, var.additional_initialization_script)}"
}