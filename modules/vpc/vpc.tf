resource "aws_vpc" "wp-multi-az-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "wp-multi-az-vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.wp-multi-az-vpc.id
}
