variable "vpc_id" {
  type = string
}

variable "local_cidr" {
  type = string
}

variable "gateway_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}
