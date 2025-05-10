resource "aws_vpc" "wp-multi-az-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "wp-multi-az-vpc"
  }
}
