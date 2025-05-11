resource "aws_subnet" "public-subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.az

  tags = {
    Name        = "public-subnet-${var.az}"
    subnet_type = "public"
  }
}

output "id" {
  value = aws_subnet.public-subnet.id
}
