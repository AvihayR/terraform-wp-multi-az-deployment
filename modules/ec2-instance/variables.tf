variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "sg_list" {
  type = set(string)
}

variable "bastion_key_name" {
  type = string
}

variable "associate_public_ip_address" {
  type = bool
}


variable "user_data" {
  type = string
}

variable "ec2_name" {
  type = string
}