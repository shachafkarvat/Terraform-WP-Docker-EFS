resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc-cidr}"

  tags = "${merge(var.default_tags, map("Name", format("%s", var.basename)))}"

  enable_dns_hostnames = true
}

# Replace with VPC module in the future 
# https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/main.tf

# Public Subnets
resource "aws_subnet" "subnet-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-a}"
  availability_zone = "${var.region}a"

  tags = "${merge(var.default_tags, map("Name", format("%s-subnet-a", var.basename)))}"
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-b}"
  availability_zone = "${var.region}b"
  tags              = "${merge(var.default_tags, map("Name", format("%s-subnet-b", var.basename)))}"
}

resource "aws_subnet" "subnet-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-c}"
  availability_zone = "${var.region}c"

  tags = "${merge(var.default_tags, map("Name", format("%s-subnet-c", var.basename)))}"
}

resource "aws_route_table" "subnet-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.basename}-rtb"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(var.default_tags, map("Name", format("%s-igw", var.basename)))}"
}

resource "aws_route" "subnet-route" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  route_table_id         = "${aws_route_table.subnet-route-table.id}"
}

resource "aws_route_table_association" "subnet-a-route-table-association" {
  subnet_id      = "${aws_subnet.subnet-a.id}"
  route_table_id = "${aws_route_table.subnet-route-table.id}"
}

resource "aws_route_table_association" "subnet-b-route-table-association" {
  subnet_id      = "${aws_subnet.subnet-b.id}"
  route_table_id = "${aws_route_table.subnet-route-table.id}"
}

resource "aws_route_table_association" "subnet-c-route-table-association" {
  subnet_id      = "${aws_subnet.subnet-c.id}"
  route_table_id = "${aws_route_table.subnet-route-table.id}"
}
