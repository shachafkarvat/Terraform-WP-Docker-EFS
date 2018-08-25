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

variable "private_subnets" {
  type = "list"
}

variable "docker_repo" {
  default = ""
}

variable "DB_NAME" {}

variable "DB_USER" {}

variable "default_tags" {
  type    = "map"
  default = {}
}

variable "logs_retention_in_days" {}
