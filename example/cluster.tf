module "cluster" {
  source  = "brantburnett/couchbase/aws"
  version = "0.1.0"

  # Switch to this line for local dev
  # source = "../"
  
  couchbase_edition      = "enterprise"
  couchbase_version      = "5.0.1"
  cluster_name           = "Couchbase Example"
  cluster_admin_password = "password"
  topology               = "${var.topology}"

  # Number of nodes for each MDS group (up to 5 groups)
  node_count = {
    "1" = 2
    "2" = 1
    "3" = 1
  }

  # Services for each MDS group
  # It is valid to include more than one service in a single MDS group
  # However, the first MDS group should at least include the data service
  # Note: If you use Community Edition, you must use a single MDS group with all services.
  services = {
    "1" = ["data"]
    "2" = ["index"]
    "3" = ["query"]
  }

  # Name for each MDS group
  group_name = {
    "1" = "Data"
    "2" = "Index"
    "3" = "Query"
  }

  # MDS setting maps will use the value from MDS group "1" if no value is specified for a specific MDS group
  instance_type = {
    "1" = "t2.large"
  }

  ebs_optimized = {
    "1" = false
  }

  data_volume = {
    "1" = {
			volume_type = "gp2" # SSD
			volume_size = "100" # Size is in GB
		}
  }

  tags = {
    "1" = [
      {
        key                 = "BillingEnvironment"
        value               = "dev"               
        propagate_at_launch = true  
      }
    ]
  }

  key_pair_name        = "${var.key_pair_name}"
  iam_instance_profile = "${var.iam_instance_profile}"

  subnet_ids = "${data.aws_subnet_ids.default.ids}"
  client_cidr_blocks = [
    # Unlimited access, not recommended for real use
    "0.0.0.0/0"
  ]

  # RAM per node used by each service.  This setting only applies when bootstrapping a new cluster,
  # changes after that should be made using the web UI or REST API.
  cluster_ram_size = {
    data = 2000
    index = 2000
    fts = 2000
  }

  # This is useful for development and new clusters, but may not be desired for large production clusters.
  # You may launch a new cluster with auto_rebalance enabled, then disable it and rerun terraform apply.
  # This will disable auto rebalance for future node adds.
  auto_rebalance = true
}