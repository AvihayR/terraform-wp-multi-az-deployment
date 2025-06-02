resource "aws_security_group" "bastion_sg" {
  name        = "Allow SSH only"
  description = "Allow SSH inbound traffic and * outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }

  egress {
    description      = "Allow * outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_to_allow]
  }
}


output "id" {
  value = aws_security_group.bastion_sg.id
}
