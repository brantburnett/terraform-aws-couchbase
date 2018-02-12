data "aws_ami" "default" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

locals {
    ami = "${var.ami == "" ? data.aws_ami.default.id : var.ami}"
}