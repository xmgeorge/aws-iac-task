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

output "lambda_api_url" {
  description = "Public URL for the serverless current-time endpoint"
  value       = module.serverless.invoke_url
}

output "lambda_function_name" {
  description = "Name of the current-time Lambda function"
  value       = module.serverless.function_name
}
