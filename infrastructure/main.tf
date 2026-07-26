module "vpc" {
  source = "./modules/vpc"

  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_count = var.public_subnet_count
}

module "web" {
  source = "./modules/web"

  project            = var.project
  vpc_id             = module.vpc.vpc_id
  subnet_id          = module.vpc.public_subnet_ids[0]
  instance_type      = var.instance_type
  allowed_http_cidrs = var.allowed_http_cidrs
}
