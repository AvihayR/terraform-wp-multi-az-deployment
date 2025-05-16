resource "aws_security_group" "rds_sg" {
  name        = "security-group-for-WP-RDS-DB"
  description = "Allow MySQL, ICMP, inbound traffic from local VPC, and all outbound traffic."
  vpc_id      = var.vpc_id

  tags = {
    Name = "wp_multi_az_rds_sg"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow MySQL (TCP 3306)"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.local_vpc_cidr, ]
  }

  ingress {
    description = "Allow ICMP inbound"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = [var.local_vpc_cidr, ]
  }
}


output "id" {
  value = aws_security_group.rds_sg.id
}
