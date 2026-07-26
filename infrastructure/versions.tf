terraform {
  # Floor for stable, current syntax. The `use_lockfile` backend option below
  # additionally requires Terraform >= 1.10.
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
   
  }
}