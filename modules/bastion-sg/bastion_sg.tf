resource "aws_security_group" "bastion_sg" {
  name        = "Allow SSH"
  description = "Allow SSH, HTTP, HTTPS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.cidr_block_to_allow
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.cidr_block_to_allow
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.cidr_block_to_allow
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

output "id" {
  value = aws_security_group.bastion_sg.id
}
