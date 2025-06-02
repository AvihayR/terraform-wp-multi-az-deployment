resource "aws_subnet" "private_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.az

  tags = {
    Name        = "private-subnet-${var.az}"
    subnet_type = "private"
  }
}

output "id" {
  value = aws_subnet.private_subnet.id
}
