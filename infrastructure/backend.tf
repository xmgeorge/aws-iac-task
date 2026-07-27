terraform {

  backend "s3" {
    bucket       = "aws-iac-task-tfstate-774305572856"
    key          = "infrastructure/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true 
  }
}
