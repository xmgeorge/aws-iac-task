output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web server"
  value       = aws_instance.web.public_dns
}

output "url" {
  description = "HTTP endpoint served by the web server"
  value       = "http://${aws_instance.web.public_ip}"
}
