terraform {
  # Remote state in S3 with a DynamoDB lock table. These two resources are
  # bootstrapped out-of-band (see the README) because they must exist before
  # Terraform can use them as its backend.
  backend "s3" {
    bucket       = "aws-iac-task-tfstate-774305572856"
    key          = "infrastructure/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true # native S3 state locking (Terraform >= 1.10)
  }
}
