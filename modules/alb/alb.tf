resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP inbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow ICMP inbound"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow * outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
}


output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "arn" {
  value = aws_lb.alb.arn
}