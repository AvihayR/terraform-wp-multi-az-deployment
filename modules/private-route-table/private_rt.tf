resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "private-route-table"
  }

  route {
    cidr_block = var.local_cidr
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.ngw_id
  }
}

resource "aws_route_table_association" "private_rt-association" {
  subnet_id      = var.private_subnet_id
  route_table_id = aws_route_table.private_rt.id
}
