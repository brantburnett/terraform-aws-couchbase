resource "aws_security_group" "client" {
    name_prefix = "CouchbaseClient"
    description = "Allows Couchbase protocols from clients to nodes in the cluster"
    vpc_id      = "${data.aws_subnet.first.vpc_id}"
}

resource "aws_security_group_rule" "client_rest" {
    count = "${length(var.client_security_group_ids)}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 8091
    to_port         = 8096
    protocol        = "tcp"
    source_security_group_id = "${element(var.client_security_group_ids, count.index)}"
}

resource "aws_security_group_rule" "client_restssl" {
    count = "${length(var.client_security_group_ids)}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 18091
    to_port         = 18096
    protocol        = "tcp"
    source_security_group_id = "${element(var.client_security_group_ids, count.index)}"
}

resource "aws_security_group_rule" "client_memcached" {
    count = "${length(var.client_security_group_ids)}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 11210
    to_port         = 11211
    protocol        = "tcp"
    source_security_group_id = "${element(var.client_security_group_ids, count.index)}"
}

resource "aws_security_group_rule" "client_memcached_ssl" {
    count = "${length(var.client_security_group_ids)}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 11207
    to_port         = 11207
    protocol        = "tcp"
    source_security_group_id = "${element(var.client_security_group_ids, count.index)}"
}

resource "aws_security_group_rule" "client_rest_cidr" {
    count = "${length(var.client_cidr_blocks) > 0 ? 1 : 0}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 8091
    to_port         = 8096
    protocol        = "tcp"
    cidr_blocks     = "${var.client_cidr_blocks}"
}

resource "aws_security_group_rule" "client_restssl_cidr" {
    count = "${length(var.client_cidr_blocks) > 0 ? 1 : 0}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 18091
    to_port         = 18096
    protocol        = "tcp"
    cidr_blocks     = "${var.client_cidr_blocks}"
}

resource "aws_security_group_rule" "client_memcached_cidr" {
    count = "${length(var.client_cidr_blocks) > 0 ? 1 : 0}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 11210
    to_port         = 11211
    protocol        = "tcp"
    cidr_blocks     = "${var.client_cidr_blocks}"
}

resource "aws_security_group_rule" "client_memcached_ssl_cidr" {
    count = "${length(var.client_cidr_blocks) > 0 ? 1 : 0}"
    security_group_id = "${aws_security_group.client.id}"

    type            = "ingress"
    from_port       = 11207
    to_port         = 11207
    protocol        = "tcp"
    cidr_blocks     = "${var.client_cidr_blocks}"
}