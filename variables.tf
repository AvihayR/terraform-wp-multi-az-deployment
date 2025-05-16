variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  default = {
    "az-a" = "eu-central-1a"
    "az-b" = "eu-central-1b"
    "az-c" = "eu-central-1c"
  }
}

variable "public_subnet_cidr_block" {
  default = {
    "az-a" = "10.0.100.0/24"
    "az-b" = "10.0.200.0/24"
    "az-c" = "10.0.254.0/24"
  }
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type    = string
  default = "wpdb"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "bastion_sg_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}


variable "bastion_key_name" {
  type    = string
  default = "bastion_key"
}
