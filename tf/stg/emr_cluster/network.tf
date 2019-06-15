# NETWORKS

resource "aws_vpc" "ml_pipeline_vpc" {
    cidr_block = "168.31.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_subnet" "ml_pipeline_subnet" {
    vpc_id = "${aws_vpc.ml_pipeline_vpc.id}"
    cidr_block = "168.31.0.0/20"
}

resource "aws_internet_gateway" "ml_pipeline_gw" {
    vpc_id = "${aws_vpc.ml_pipeline_vpc.id}"
}

resource "aws_route_table" "ml_pipeline_route_table" {
    vpc_id = "${aws_vpc.ml_pipeline_vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.ml_pipeline_gw.id}"
    }
}

resource "aws_main_route_table_association" "ml_pipeline_route_table_association" {
    vpc_id = "${aws_vpc.ml_pipeline_vpc.id}"
    route_table_id = "${aws_route_table.ml_pipeline_route_table.id}"
}

# SECURITY GROUPS

resource "aws_security_group" "allow_access" {
    name = "allow_access"
    description = "Allow inbound traffic"
    vpc_id = "${aws_vpc.ml_pipeline_vpc.id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"

        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    depends_on = ["aws_subnet.ml_pipeline_subnet"]

    lifecycle {
        ignore_changes = ["ingress", "egress"]
    }
}