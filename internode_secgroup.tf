data "aws_subnet" "first" {
    id = "${element(var.subnet_ids, 0)}"
}

resource "aws_security_group" "internode" {
    name        = "Couchbase Inter-Node"
    description = "Allows Couchbase protocols between nodes in the cluster"
    vpc_id      = "${data.aws_subnet.first.vpc_id}"
}

resource "aws_security_group_rule" "egress" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "egress"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "erlang_port_mapper" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 4369
    to_port         = 4369
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}

resource "aws_security_group_rule" "rest" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 8091
    to_port         = 8094
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}

resource "aws_security_group_rule" "indexer" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 9100
    to_port         = 9105
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}

resource "aws_security_group_rule" "projector" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 9999
    to_port         = 9999
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}

resource "aws_security_group_rule" "memcached" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 11209
    to_port         = 11210
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}

resource "aws_security_group_rule" "internal" {
    security_group_id = "${aws_security_group.internode.id}"

    type            = "ingress"
    from_port       = 21100
    to_port         = 21299
    protocol        = "tcp"
    source_security_group_id = "${aws_security_group.internode.id}"
}