terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

locals {
	built_installer_url    = "http://packages.couchbase.com/releases/${var.couchbase_version}/couchbase-server-${var.couchbase_edition}-${var.couchbase_version}-centos6.x86_64.rpm"
	installer_url          = "${coalesce(var.installer_url, local.built_installer_url)}"

	major_version          = "${element(split(".", var.couchbase_version), 0)}"
	minor_version          = "${element(split(".", var.couchbase_version), 1)}"
}

resource "aws_launch_configuration" "node" {
  count = "${var.node_count > 0 ? 1 : 0}"

  name_prefix                 = "${replace("${var.cluster_name} ${var.name}", " ", "-")}"
  image_id                    = "${local.ami}"
  instance_type               = "${var.instance_type}"
  enable_monitoring           = "${var.detailed_monitoring}"

  key_name                    = "${var.key_pair_name}"
  security_groups             = ["${var.security_group_ids}"]
  iam_instance_profile        = "${var.iam_instance_profile}"
  associate_public_ip_address = "${var.topology == "public"}"
  
  root_block_device           = ["${var.boot_volume}"]
  ebs_block_device            = ["${merge(var.data_volume, map("device_name", "/dev/sdb"))}"]
  ebs_optimized               = "${var.ebs_optimized}"

  placement_tenancy           = "${var.placement_tenancy}"

  user_data                   = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "node" {
  count = "${var.node_count > 0 ? 1 : 0}"

  name_prefix          = "${replace("${var.cluster_name} ${var.name}", " ", "-")}"
  launch_configuration = "${aws_launch_configuration.node.name}"
  min_size             = "${var.node_count}"
  max_size             = "${var.node_count}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.cluster_name} ${var.name}", "propagate_at_launch", "true"),
      map("key", "Services", "value", join(",", var.services), "propagate_at_launch", "true")
    ),
    var.tags)
  }"]
}

data "aws_region" "current" {}

data "template_file" "user_data" {
  count = "${var.node_count > 0 ? 1 : 0}"

  template = "${file("${path.module}/userdata.tpl.sh")}"

  vars {
    region                           = "${data.aws_region.current.name}"
    apply_updates                    = "${var.apply_updates ? "echo \"Applying updates...\"\nyum update -y": "echo \"Skipping updates\""}"
    installer_url                    = "${local.installer_url}"
    couchbase_edition                = "${var.couchbase_edition}"
    
    topology                         = "${var.topology}"
    cluster_name                     = "${var.cluster_name}"
    cluster_name_init                = "${local.major_version >= 5 ? var.cluster_name : ""}"
    cluster_admin_username           = "${var.cluster_admin_username}"
    cluster_admin_password           = "${var.cluster_admin_password}"
    index_storage                    = "${var.cluster_index_storage}"
    data_ramsize                     = "${var.cluster_ram_size["data"]}"
    index_ramsize                    = "${var.cluster_ram_size["index"]}"
    fts_ramsize                      = "${var.cluster_ram_size["fts"]}"
    services                         = "${join(",", var.services)}"
    rally_autoscaling_group_id       = "${var.rally_autoscaling_group_id}"

    additional_initialization_script = "${var.additional_initialization_script}"
    auto_rebalance                   = "${var.auto_rebalance}"
  }
}