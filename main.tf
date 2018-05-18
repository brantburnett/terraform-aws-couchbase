terraform {
  required_version = ">= 0.10.3" # introduction of Local Values configuration language feature
}

locals {
  iam_instance_profile = "${element(concat(compact(list(var.iam_instance_profile)), aws_iam_instance_profile.couchbase.*.name), 0)}"
}

module "mds_group_1" {
  source = "./mds-group"

  cluster_name                     = "${var.cluster_name}"
  cluster_admin_username           = "${var.cluster_admin_username}"
  cluster_admin_password           = "${var.cluster_admin_password}"
  cluster_index_storage            = "${var.cluster_index_storage}"
  cluster_ram_size                 = "${var.cluster_ram_size}"
  analytics_mpp                    = "${var.analytics_mpp}"
  installer_url                    = "${var.installer_url}"
  couchbase_version                = "${var.couchbase_version}"
  couchbase_edition                = "${var.couchbase_edition}"

  key_pair_name                    = "${var.key_pair_name}"
  ami                              = "${var.ami}"
  apply_updates                    = "${var.apply_updates}"
  subnet_ids                       = "${var.subnet_ids}"
  security_group_ids               = "${concat(var.security_group_ids, list(aws_security_group.internode.id, aws_security_group.client.id))}"
  topology                         = "${var.topology}"
  iam_instance_profile             = "${local.iam_instance_profile}"
  termination_protection           = "${var.termination_protection}"
  detailed_monitoring              = "${var.detailed_monitoring}"
  placement_tenancy                = "${var.placement_tenancy}"
  boot_volume                      = "${var.boot_volume}"

  name                             = "${local.group_name["1"]}"
  node_count                       = "${local.node_count["1"]}"
  tags                             = "${local.tags["1"]}"  
  services                         = "${local.services["1"]}"  
  instance_type                    = "${local.instance_type["1"]}"  
  data_volume                      = "${local.data_volume["1"]}"
  ebs_optimized                    = "${local.ebs_optimized["1"]}"
  additional_initialization_script = "${local.additional_initialization_script["1"]}"
  auto_rebalance                   = "${var.auto_rebalance}"

  rally_autoscaling_group_id       = ""
}

module "mds_group_2" {
  source = "./mds-group"

  cluster_name                     = "${var.cluster_name}"
  cluster_admin_username           = "${var.cluster_admin_username}"
  cluster_admin_password           = "${var.cluster_admin_password}"
  cluster_index_storage            = "${var.cluster_index_storage}"
  cluster_ram_size                 = "${var.cluster_ram_size}"
  analytics_mpp                    = "${var.analytics_mpp}"
  installer_url                    = "${var.installer_url}"
  couchbase_version                = "${var.couchbase_version}"
  couchbase_edition                = "${var.couchbase_edition}"

  key_pair_name                    = "${var.key_pair_name}"
  ami                              = "${var.ami}"
  apply_updates                    = "${var.apply_updates}"
  subnet_ids                       = "${var.subnet_ids}"
  security_group_ids               = "${concat(var.security_group_ids, list(aws_security_group.internode.id, aws_security_group.client.id))}"
  topology                         = "${var.topology}"
  iam_instance_profile             = "${local.iam_instance_profile}"
  termination_protection           = "${var.termination_protection}"
  detailed_monitoring              = "${var.detailed_monitoring}"
  placement_tenancy                = "${var.placement_tenancy}"
  boot_volume                      = "${var.boot_volume}"

  name                             = "${local.group_name["2"]}"
  node_count                       = "${local.node_count["2"]}"
  tags                             = "${local.tags["2"]}"  
  services                         = "${local.services["2"]}"  
  instance_type                    = "${local.instance_type["2"]}"  
  data_volume                      = "${local.data_volume["2"]}"
  ebs_optimized                    = "${local.ebs_optimized["2"]}"
  additional_initialization_script = "${local.additional_initialization_script["2"]}"
  auto_rebalance                   = "${var.auto_rebalance}"

  rally_autoscaling_group_id       = "${module.mds_group_1.autoscaling_group_id}"
}

module "mds_group_3" {
  source = "./mds-group"

  cluster_name                     = "${var.cluster_name}"
  cluster_admin_username           = "${var.cluster_admin_username}"
  cluster_admin_password           = "${var.cluster_admin_password}"
  cluster_index_storage            = "${var.cluster_index_storage}"
  cluster_ram_size                 = "${var.cluster_ram_size}"
  analytics_mpp                    = "${var.analytics_mpp}"
  installer_url                    = "${var.installer_url}"
  couchbase_version                = "${var.couchbase_version}"
  couchbase_edition                = "${var.couchbase_edition}"

  key_pair_name                    = "${var.key_pair_name}"
  ami                              = "${var.ami}"
  apply_updates                    = "${var.apply_updates}"
  subnet_ids                       = "${var.subnet_ids}"
  security_group_ids               = "${concat(var.security_group_ids, list(aws_security_group.internode.id, aws_security_group.client.id))}"
  topology                         = "${var.topology}"
  iam_instance_profile             = "${local.iam_instance_profile}"
  termination_protection           = "${var.termination_protection}"
  detailed_monitoring              = "${var.detailed_monitoring}"
  placement_tenancy                = "${var.placement_tenancy}"
  boot_volume                      = "${var.boot_volume}"

  name                             = "${local.group_name["3"]}"
  node_count                       = "${local.node_count["3"]}"
  tags                             = "${local.tags["3"]}"  
  services                         = "${local.services["3"]}"  
  instance_type                    = "${local.instance_type["3"]}"  
  data_volume                      = "${local.data_volume["3"]}"
  ebs_optimized                    = "${local.ebs_optimized["3"]}"
  additional_initialization_script = "${local.additional_initialization_script["3"]}"
  auto_rebalance                   = "${var.auto_rebalance}"

  rally_autoscaling_group_id       = "${module.mds_group_1.autoscaling_group_id}"
}

module "mds_group_4" {
  source = "./mds-group"

  cluster_name                     = "${var.cluster_name}"
  cluster_admin_username           = "${var.cluster_admin_username}"
  cluster_admin_password           = "${var.cluster_admin_password}"
  cluster_index_storage            = "${var.cluster_index_storage}"
  cluster_ram_size                 = "${var.cluster_ram_size}"
  analytics_mpp                    = "${var.analytics_mpp}"
  installer_url                    = "${var.installer_url}"
  couchbase_version                = "${var.couchbase_version}"
  couchbase_edition                = "${var.couchbase_edition}"

  key_pair_name                    = "${var.key_pair_name}"
  ami                              = "${var.ami}"
  apply_updates                    = "${var.apply_updates}"
  subnet_ids                       = "${var.subnet_ids}"
  security_group_ids               = "${concat(var.security_group_ids, list(aws_security_group.internode.id, aws_security_group.client.id))}"
  topology                         = "${var.topology}"
  iam_instance_profile             = "${local.iam_instance_profile}"
  termination_protection           = "${var.termination_protection}"
  detailed_monitoring              = "${var.detailed_monitoring}"
  placement_tenancy                = "${var.placement_tenancy}"
  boot_volume                      = "${var.boot_volume}"

  name                             = "${local.group_name["4"]}"
  node_count                       = "${local.node_count["4"]}"
  tags                             = "${local.tags["4"]}"  
  services                         = "${local.services["4"]}"  
  instance_type                    = "${local.instance_type["4"]}"  
  data_volume                      = "${local.data_volume["4"]}"
  ebs_optimized                    = "${local.ebs_optimized["4"]}"
  additional_initialization_script = "${local.additional_initialization_script["4"]}"
  auto_rebalance                   = "${var.auto_rebalance}"

  rally_autoscaling_group_id       = "${module.mds_group_1.autoscaling_group_id}"
}

module "mds_group_5" {
  source = "./mds-group"

  cluster_name                     = "${var.cluster_name}"
  cluster_admin_username           = "${var.cluster_admin_username}"
  cluster_admin_password           = "${var.cluster_admin_password}"
  cluster_index_storage            = "${var.cluster_index_storage}"
  cluster_ram_size                 = "${var.cluster_ram_size}"
  analytics_mpp                    = "${var.analytics_mpp}"
  installer_url                    = "${var.installer_url}"
  couchbase_version                = "${var.couchbase_version}"
  couchbase_edition                = "${var.couchbase_edition}"

  key_pair_name                    = "${var.key_pair_name}"
  ami                              = "${var.ami}"
  apply_updates                    = "${var.apply_updates}"
  subnet_ids                       = "${var.subnet_ids}"
  security_group_ids               = "${concat(var.security_group_ids, list(aws_security_group.internode.id, aws_security_group.client.id))}"
  topology                         = "${var.topology}"
  iam_instance_profile             = "${local.iam_instance_profile}"
  termination_protection           = "${var.termination_protection}"
  detailed_monitoring              = "${var.detailed_monitoring}"
  placement_tenancy                = "${var.placement_tenancy}"
  boot_volume                      = "${var.boot_volume}"

  name                             = "${local.group_name["5"]}"
  node_count                       = "${local.node_count["5"]}"
  tags                             = "${local.tags["5"]}"  
  services                         = "${local.services["5"]}"  
  instance_type                    = "${local.instance_type["5"]}"  
  data_volume                      = "${local.data_volume["5"]}"
  ebs_optimized                    = "${local.ebs_optimized["5"]}"
  additional_initialization_script = "${local.additional_initialization_script["5"]}"
  auto_rebalance                   = "${var.auto_rebalance}"

  rally_autoscaling_group_id       = "${module.mds_group_1.autoscaling_group_id}"
}