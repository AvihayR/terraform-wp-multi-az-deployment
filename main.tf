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
  rds_subnet_group = [module.public-subnet-a.id, module.public-subnet-b.id]
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
}

module "application_load_balancer" {
  source        = "./modules/alb"
  public_subnet_ids = [module.public-subnet-a.id, module.public-subnet-b.id]
  vpc_id = module.vpc.vpc_id
}

module "wp_instance" {
  for_each = {a = module.private_subnet_a.id, b = module.private_subnet_b.id}
  source                      = "./modules/ec2-instance"
  instance_type               = var.instance_type
  subnet_id                   = each.value
  sg_list                     = [module.wp_sg.id]
  bastion_key_name            = module.bastion_key_pair.key_pair.key_name
  ec2_name                    = "wp_instance_${each.key}"
  user_data                   = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install -y mariadb10.5
    sudo amazon-linux-extras install -y php8.2
    sudo yum install -y httpd
    sudo yum install -y git
    # sudo yum install -y php-xml

    sudo systemctl start httpd
    sudo systemctl enable httpd

    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo mv wordpress/* /var/www/html/
    git clone ${var.wp_blog_repo}
    sudo mv wp-blog/wp-content/* /var/www/html/wp-content

    sudo usermod -a -G apache ec2-user
    # sudo chown -R ec2-user:apache /var/www
    sudo chown -R apache:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;

    DB_USER="${var.db_username}"
    DB_PASS="${var.db_password}"
    DB_HOST="${module.rds.endpoint}"

    # Write SQL commands to a temp file
    cat <<SQL > /tmp/init_wp.sql
    # CREATE DATABASE \`${var.db_name}\`;
    GRANT ALL PRIVILEGES ON \`${var.db_name}\`.* TO '$DB_USER'@'%';
    FLUSH PRIVILEGES;
    SQL

    # Run the SQL script
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < /tmp/init_wp.sql

    # Initialize Wordpress connection to DB
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < wp-blog-demo-app/wpdb.sql
    sudo sed -i 's/'database_name_here'/'${var.db_name}'/g' /var/www/html/wp-config.php
    sudo sed -i 's/'username_here'/'${var.db_username}'/g' /var/www/html/wp-config.php
    sudo sed -i 's/'password_here'/'${var.db_password}'/g' /var/www/html/wp-config.php
    sudo sed -i 's/'localhost'/'${module.rds.endpoint}'/g' /var/www/html/wp-config.php

    # Load wp db backup
    sudo sed -i 's/'YOUR_RDS_ENDPOINT'/'${module.rds.endpoint}'/g' wp-blog/sql/wp-db-backup.sql
    sudo sed -i "s#YOUR_ALB_DNS_NAME#http://${module.application_load_balancer.lb_dns_name}#g" wp-blog/sql/wp-db-backup.sql
    mysql -u"$DB_USER" -p"$DB_PASS" -h "$DB_HOST" < wp-blog/sql/wp-db-backup.sql
    echo "${module.application_load_balancer.lb_dns_name}" > /home/ec2-user/alb.txt
  EOT
  associate_public_ip_address = false
}


module "alb_tg" {
  source = "./modules/alb-tg"
  alb_arn = module.application_load_balancer.arn
  instance_id_list = [module.wp_instance.a.id, module.wp_instance.b.id]
  vpc_id = module.vpc.vpc_id
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
