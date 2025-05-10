module "vpc" {
  source   = "./modules"
  vpc_cidr = var.vpc_cidr
}
