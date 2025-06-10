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

resource "aws_lb_target_group" "tg" {
  name = "alb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

    health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher = "200,302"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "wp_tg" {
  count = length(var.instance_id_list)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.instance_id_list[count.index]
  port             = 80
}

resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
}


resource "aws_lb_listener" "wp_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}
