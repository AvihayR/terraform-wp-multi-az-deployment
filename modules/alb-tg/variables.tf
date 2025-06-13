variable "vpc_id" {
  type = string
}

variable "instance_id_list" {
  type = list(string)
}

variable "alb_arn" {
  type = string
}