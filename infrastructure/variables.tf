

variable "project" {
  default = "demo"
}

variable "environment" {
  default = "dev"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_count" {
  default = 2
  type    = number
}