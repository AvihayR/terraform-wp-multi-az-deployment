resource "aws_eip" "eip" {
  tags = {
    "Name" = "Elastic IP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip.allocation_id
  subnet_id     = var.subnet_id

  tags = {
    Name = "NAT Gateway for private-subnet's outbound traffic"
  }
}
