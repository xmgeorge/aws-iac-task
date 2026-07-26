variable "project" {
  description = "Name prefix for resource names and tags"
  type        = string
}

variable "vpc_id" {
  description = "VPC to place the web server in"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet for the web server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR ranges allowed to reach the web server on port 80"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
