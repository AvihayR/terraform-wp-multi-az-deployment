module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "public-subnet-a" {
  source     = "./modules/public-subnet"
  vpc_id     = module.vpc.vpc_id
  cidr_block = lookup(var.public_subnet_cidr_block, "az-a")
  az         = lookup(var.availability_zone, "az-a")
}

module "public-subnet-b" {
  source     = "./modules/public-subnet"
  vpc_id     = module.vpc.vpc_id
  cidr_block = lookup(var.public_subnet_cidr_block, "az-b")
  az         = lookup(var.availability_zone, "az-b")
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}
