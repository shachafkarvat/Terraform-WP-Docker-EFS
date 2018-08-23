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

variable "artefacts_s3" {}
