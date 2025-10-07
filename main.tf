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


module "private_subnet_a" {
  source     = "./modules/private_subnet"
  vpc_id     = module.vpc.vpc_id
  cidr_block = lookup(var.private_subnet_cidr_block, "az-a")
  az         = lookup(var.availability_zone, "az-a")
}

module "private_subnet_b" {
  source     = "./modules/private_subnet"
  vpc_id     = module.vpc.vpc_id
  cidr_block = lookup(var.private_subnet_cidr_block, "az-b")
  az         = lookup(var.availability_zone, "az-b")
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat_gw_a" {
  source     = "./modules/nat-gw"
  subnet_id  = module.public-subnet-a.id
  depends_on = [module.igw]
}

module "nat_gw_b" {
  source     = "./modules/nat-gw"
  subnet_id  = module.public-subnet-b.id
  depends_on = [module.igw]
}

module "public_route_table" {
  source            = "./modules/public-route-table"
  vpc_id            = module.vpc.vpc_id
  local_cidr        = var.vpc_cidr
  gateway_id        = module.igw.igw-id
  public_subnet_ids = [module.public-subnet-a.id, module.public-subnet-b.id]
}

module "private_route_tables" {
  for_each = {
    "subnet-a" = {
      subnet_id = module.private_subnet_a.id
      nat_id    = module.nat_gw_a.id
    }
    "subnet-b" = {
      subnet_id = module.private_subnet_b.id
      nat_id    = module.nat_gw_b.id
    }
  }

  source            = "./modules/private-route-table"
  vpc_id            = module.vpc.vpc_id
  local_cidr        = var.vpc_cidr
  private_subnet_id = each.value.subnet_id
  ngw_id            = each.value.nat_id
}

module "rds_sg" {
  source         = "./modules/rds_sg"
  vpc_id         = module.vpc.vpc_id
  local_vpc_cidr = var.vpc_cidr
}

module "rds" {
  source           = "./modules/rds"
  rds_subnet_group = [module.private_subnet_a.id, module.private_subnet_b.id]
  username         = var.db_username
  password         = var.db_password
  db_name          = var.db_name
  sg_id_list       = [module.rds_sg.id, ]
}

module "bastion_sg" {
  source              = "./modules/bastion-sg"
  vpc_id              = module.vpc.vpc_id
  cidr_block_to_allow = var.bastion_sg_allowed_cidr
}

module "wp_sg" {
  source              = "./modules/wp-instance-sg"
  vpc_id              = module.vpc.vpc_id
  cidr_block_to_allow = module.vpc.vpc_cidr_block
}

module "bastion_key_pair" {
  source   = "./modules/ec2_keypair"
  key_name = var.bastion_key_name
}

module "bastion_instance" {
  source                      = "./modules/ec2-instance"
  instance_type               = var.instance_type
  subnet_id                   = module.public-subnet-a.id
  sg_list                     = [module.bastion_sg.id]
  bastion_key_name            = module.bastion_key_pair.key_pair.key_name
  ec2_name                    = "bastion-host"
  user_data                   = null
  associate_public_ip_address = true
  instance_profile            = null
}

module "ssm_parameters" {
  source      = "./modules/ssm_params"
  db_username = var.db_username
  db_password = var.db_password
}

module "ssm_instance_profile" {
  source = "./modules/ssm_instance_profile"
}

module "application_load_balancer" {
  source            = "./modules/alb"
  public_subnet_ids = [module.public-subnet-a.id, module.public-subnet-b.id]
  vpc_id            = module.vpc.vpc_id
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "wp-ecr-dkr"
  region    = var.region
}


module "wp_instance" {
  for_each                    = { a = module.private_subnet_a.id, b = module.private_subnet_b.id }
  source                      = "./modules/ec2-instance"
  instance_type               = var.instance_type
  subnet_id                   = each.value
  sg_list                     = [module.wp_sg.id]
  bastion_key_name            = module.bastion_key_pair.key_pair.key_name
  ec2_name                    = "wp_instance_${each.key}"
  instance_profile            = module.ssm_instance_profile.name
  user_data                   = <<-EOT
    #!/bin/bash
    # Connect instance to ECS cluster
    sudo echo ECS_CLUSTER=${module.ecs_cluster.name} >> /etc/ecs/ecs.config
  EOT
  associate_public_ip_address = false
}


module "alb_tg" {
  source           = "./modules/alb-tg"
  alb_arn          = module.application_load_balancer.arn
  instance_id_list = [module.wp_instance.a.id, module.wp_instance.b.id]
  vpc_id           = module.vpc.vpc_id
}

module "ecs_cluster" {
  source      = "./modules/ecs"
  db_name     = var.db_name
  db_user     = var.db_username
  db_password = var.db_password
  db_url      = module.rds.endpoint
  repo_url    = module.ecr.url
}


# Outputs
# -------------------------------


output "public_subnet_ids" {
  value = [module.public-subnet-a.id, module.public-subnet-b.id]
}

output "igw" {
  value = module.igw
}

output "rds_details" {
  value = module.rds
}

output "keypair" {
  value = module.bastion_key_pair
}

output "wp_instances" {
  value = module.wp_instance
}

output "bastion_ec2_instance" {
  value = module.bastion_instance
}

output "alb_dns_name" {
  value = module.application_load_balancer
}

output "ecr_url" {
  value = module.ecr.url
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.name
}

output "task_definition_arn" {
  value = module.ecs_cluster.td_arn
}
