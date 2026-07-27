output "state_bucket_name" {
  description = "S3 bucket for remote state — copy this into infrastructure/backend.tf"
  value       = aws_s3_bucket.state.bucket
}
