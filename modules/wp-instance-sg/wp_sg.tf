resource "aws_security_group" "wp_sg" {
  name        = "Allow SSH, HTTP/S, ICMP from local CIDR"
  description = "Allow SSH, HTTP, HTTPS, ICMP inbound traffic and * outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "wp-sg"
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

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_to_allow]
  }


  ingress {
    description = "Allow HTTPS inbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block_to_allow]
  }

  ingress {
    description = "Allow ICMP inbound"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = [var.cidr_block_to_allow]
  }
}


output "id" {
  value = aws_security_group.wp_sg.id
}
