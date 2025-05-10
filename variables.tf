variable "region" {
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zone" {
  default = {
    "az-a" = "eu-central-1a"
    "az-b" = "eu-central-1b"
    "az-c" = "eu-central-1c"
  }
}

