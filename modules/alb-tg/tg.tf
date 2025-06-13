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

resource "aws_lb_listener" "wp_listener" {
  load_balancer_arn = var.alb_arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}