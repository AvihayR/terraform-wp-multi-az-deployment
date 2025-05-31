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


module "public-route-table" {
  source            = "./modules/public-route-table"
  vpc_id            = module.vpc.vpc_id
  local_cidr        = var.vpc_cidr
  gateway_id        = module.igw.igw-id
  public_subnet_ids = [module.public-subnet-a.id, module.public-subnet-b.id]
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
  cidr_block_to_allow = var.bastion_sg_allowed_cidr
  vpc_id              = module.vpc.vpc_id
}

module "bastion_key_pair" {
  source   = "./modules/ec2_keypair"
  key_name = var.bastion_key_name
}

module "wp_ec2_instance" {
  source                      = "./modules/ec2-instance"
  instance_type               = var.instance_type
  subnet_id                   = module.public-subnet-a.id
  sg_list                     = [module.bastion_sg.id]
  bastion_key_name            = module.bastion_key_pair.key_pair.key_name
  user_data                   = <<-EOT
    #!/bin/bash
    sudo yum update -y
    sudo amazon-linux-extras install -y mariadb10.5
    sudo amazon-linux-extras install -y php8.2
    sudo yum install -y httpd
    sudo yum install -y git

    sudo systemctl start httpd
    sudo systemctl enable httpd

    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www
    sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
    find /var/www -type f -exec sudo chmod 0664 {} \;

    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    sudo mv wordpress/* /var/www/html/

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

    # cat <<EOL >> /var/www/html/wp-config.php
    #   define( 'AUTH_KEY',         '^skfI})#j$n}JaN7o#UH!ob(mLr$WVX6FTYw9J}mQ<:vI*v8p2$~hGg>>E-XGG?^' );
    #   define( 'SECURE_AUTH_KEY',  '4&!Fa!1^B[R$i=sC5Vtkp#=xmkQSsDg W3GB&/1z}lj,/iP[q%:JG|*_,+.vwJ*;' );
    #   define( 'LOGGED_IN_KEY',    ';gd_NORGtCQzx!EBgC9AeUsDt:#>480.e.L)=#v}HuGr^Z%u o4D=Be3BSm6$A/9' );
    #   define( 'NONCE_KEY',        '+}gdvR-fHW5NH#B&HIQ%rns1>)d&jQ[5Ro2EfgCBZ7^6|A}<Xrf<u:S2*L1=@sOQ' );
    #   define( 'AUTH_SALT',        '[c*abR6{tpSa/Y54nxx8&;(D~ElJ1L~7XP=0PVSH,SD)9Gt+i)  1X&4<rw-Thd!' );
    #   define( 'SECURE_AUTH_SALT', 'C>ha@-0k(UPA2P|m$S}+#eO$md*d<K;x^+sS&9?R,6;t&B@Y=z{Y(S8EB8#q@TJ)' );
    #   define( 'LOGGED_IN_SALT',   'UV$Q$(8aWcl;nXVM^*H)Qb2B%5)TSPiaBX*-C<B]=w>{y_eZ%:u0.yk/G{dEw8<~' );
    #   define( 'NONCE_SALT',       '(V/<C!Zusm5^zFsj-@V R)A+3.7l%&h~6.!<zM|~N9SiecsaR7&X:dH|h VLhZ2A' );
    # EOL
  EOT
  associate_public_ip_address = false
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

output "rds_details" {
  value = module.rds
}

output "wp_ec2_instance" {
  value = module.wp_ec2_instance
}

output "keypair" {
  value = module.bastion_key_pair
}
