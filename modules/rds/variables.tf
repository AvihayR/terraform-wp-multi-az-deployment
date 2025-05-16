variable "username" {
  type = string
}


variable "password" {
  type = string
}


variable "db_name" {
  type = string
}

variable "rds_subnet_group" {
  type = set(string)
}

variable "sg_id_list" {
  type = set(string)
}
