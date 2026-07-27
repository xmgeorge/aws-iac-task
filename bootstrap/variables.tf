variable "project" {
  description = "Name prefix for resource names and tags"
  type        = string
  default     = "aws-iac-task"
}

variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "eu-west-2"
}
