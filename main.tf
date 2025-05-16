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


module "public-route-table" {
  source            = "./modules/public-route-table"
  local_cidr        = var.vpc_cidr
  vpc_id            = module.vpc.vpc_id
  gateway_id        = module.igw.igw-id
  public_subnet_ids = [module.public-subnet-a.id, module.public-subnet-b.id]
}


module "rds" {
  source           = "./modules/rds"
  rds_subnet_group = [module.public-subnet-a.id, module.public-subnet-b.id]
  username         = var.db_username
  password         = var.db_password
  db_name          = var.db_name
}

module "bastion_sg" {
  source              = "./modules/bastion-sg"
  cidr_block_to_allow = var.bastion_sg_allowed_cidr
  vpc_id              = module.vpc.vpc_id
}

module "bastion_key_pair" {
  source   = "./modules/ec2_keypair"
  key_name = var.bastion_key_name
}

module "wp_ec2_instance" {
  source           = "./modules/ec2-instance"
  instance_type    = var.instance_type
  subnet_id        = module.public-subnet-a.id
  sg_list          = [module.bastion_sg.id]
  bastion_key_name = module.bastion_key_pair.key_pair.key_name
}


# -------------------------------
# Outputs
# -------------------------------

output "public_subnet_ids" {
  value = [module.public-subnet-a.id, module.public-subnet-b.id]
}

output "igw" {
  value = module.igw
}

output "rds_arn" {
  value = module.rds
}

output "wp_ec2_instance" {
  value = module.wp_ec2_instance
}

output "keypair" {
  value = module.bastion_key_pair
}
