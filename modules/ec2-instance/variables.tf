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
