provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "taurak.co.uk.terraform"
    region = "eu-west-2"
    key    = "state/taurak.co.uk/"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc-cidr}"

  tags {
    Name = "${var.basename}"
  }

  enable_dns_hostnames = true
}

# Public Subnets
resource "aws_subnet" "subnet-a" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-a}"
  availability_zone = "${var.region}a"

  tags {
    Name = "${var.basename}-${var.regionshort}-a"
  }
}

resource "aws_subnet" "subnet-b" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-b}"
  availability_zone = "${var.region}b"

  tags {
    Name = "${var.basename}-${var.regionshort}-b"
  }
}

resource "aws_subnet" "subnet-c" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${var.subnet-cidr-c}"
  availability_zone = "${var.region}c"

  tags {
    Name = "${var.basename}-${var.regionshort}-c"
  }
}

resource "aws_route_table" "subnet-route-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.basename}-rtb"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.basename}-igw"
  }
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

## Creating AutoScaling Group

resource "aws_security_group" "elb-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "elb-sg"

  ingress = [
    {
      from_port   = "80"
      to_port     = "80"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = "443"
      to_port     = "443"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "nginx-instances-sg"

  ingress = [
    {
      from_port       = "80"
      to_port         = "80"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb-sg.id}"]
    },
    {
      from_port       = "443"
      to_port         = "443"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.elb-sg.id}"]
    },
    {
      from_port       = "22"
      to_port         = "22"
      protocol        = "tcp"
      security_groups = ["${aws_security_group.bastion-sg.id}"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.small"
  vpc_security_group_ids      = ["${aws_security_group.bastion-sg.id}"]
  subnet_id                   = "${aws_subnet.subnet-a.id}"
  associate_public_ip_address = true
  key_name                    = "${var.keyname}"

  tags {
    Name = "Bastion"
  }

  user_data = <<EOF
#!/bin/sh
apt update
hostname "BASTION"
EOF
}

resource "aws_security_group" "bastion-sg" {
  vpc_id = "${aws_vpc.vpc.id}"
  name   = "bastion-sg"

  ingress = [
    {
      from_port   = "22"
      to_port     = "22"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
