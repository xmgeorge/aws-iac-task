


module "vpc" {

  source = "./modules/vpc"

  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_count = var.public_subnet_count

}