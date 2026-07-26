


module "vpc" {

    source = "./modules/vpc"

    project = var.project
    vpc_cidr = "10.0.0.0/16"
 
}