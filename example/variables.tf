variable "region" {
    description = "AWS region for launching the cluster"
    default = "us-east-1"
}

variable "key_pair_name" {
    description = "EC2 key pair to use when launching instances"
}

variable "vpc_id" {
    description = "If supplied, uses this VPC instead of the default VPC"
    default = ""
}

variable "topology" {  
	description = "Indicates if the cluster is using public or private hostnames.  Must be either 'public' or 'private'."
	default = "public"
}

variable "iam_instance_profile" {
    description = "IAM instance profile to apply IAM roles.  If missing, a new role will be created instead.  The profile must include certain rights, consult README.md."
    default = ""
}