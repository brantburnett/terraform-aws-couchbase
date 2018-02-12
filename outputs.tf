output "autoscaling_group_ids" {
    description = "Autoscaling group IDs for all autoscaling groups"
    value = ["${compact(list(
        module.mds_group_1.autoscaling_group_id, 
        module.mds_group_2.autoscaling_group_id,
        module.mds_group_3.autoscaling_group_id,
        module.mds_group_4.autoscaling_group_id,
        module.mds_group_5.autoscaling_group_id
    ))}"]
}

output "internode_security_group_id" {
    description = "AWS security group ID of the created security group for inter-node communication"
    value = "${aws_security_group.internode.id}"
}

output "client_security_group_id" {
    description = "AWS security group ID of the created security group for client-to-node communication"
    value = "${aws_security_group.client.id}"
}