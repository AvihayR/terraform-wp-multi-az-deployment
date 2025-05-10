resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "wp-multi-az-igw"
  }
}

output "igw-id" {
  value = aws_internet_gateway.igw.id
}
