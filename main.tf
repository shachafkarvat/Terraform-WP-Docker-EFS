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
