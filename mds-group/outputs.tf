output "autoscaling_group_id" {
    description = "ID of the created autoscaling group"
    value = "${join("", aws_autoscaling_group.node.*.id)}"
}