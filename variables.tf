variable "region" {}

variable "vpc-cidr" {}

variable "subnet-cidr-a" {}

variable "subnet-cidr-b" {}

variable "subnet-cidr-c" {}

variable "create-extra-subnets" {
  default = false
}

variable "basename" {}
variable "regionshort" {}

variable "ami" {}

variable "ec2-size" {
  default = "t2.micro"
}

variable "keyname" {}
variable "r53-zone" {}

data "aws_route53_zone" "dnszone" {
  name         = "${var.r53-zone}"
  private_zone = false
}

data "aws_availability_zones" "all" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
