

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

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR ranges allowed to reach the web server on port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}