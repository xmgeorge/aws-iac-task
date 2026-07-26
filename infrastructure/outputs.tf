output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "web_url" {
  description = "Public HTTP endpoint served by the EC2 instance"
  value       = module.web.url
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = module.web.public_ip
}
