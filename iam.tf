locals {
    iam_count = "${length(var.iam_instance_profile) > 0 ? 0 : 1}"
}

resource "aws_iam_role" "couchbase" {
    count = "${local.iam_count}"
    name_prefix = "CouchbaseNode"

    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "couchbase" {
  statement {
    sid = "1"

    actions = [
        "ec2:CreateTags",
        "ec2:DescribeTags",
        "ec2:DescribeInstances",
        "autoscaling:DescribeAutoScalingGroups"
    ]

    resources = [
        "*"
    ]
  }
}

resource "aws_iam_role_policy" "couchbase" {
    count = "${local.iam_count}"

    name   = "rally_access"
    role   = "${aws_iam_role.couchbase.id}"
    policy = "${data.aws_iam_policy_document.couchbase.json}"
}

resource "aws_iam_instance_profile" "couchbase" {
    count = "${local.iam_count}"

    name_prefix = "couchbase"
    role        = "${aws_iam_role.couchbase.name}"
}