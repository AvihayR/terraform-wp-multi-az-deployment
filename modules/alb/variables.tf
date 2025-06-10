variable "vpc_id" {
  type = string
}

variable "instance_id_list" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}