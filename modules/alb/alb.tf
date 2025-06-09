resource "aws_lb" "alb" {
  name               = "wp-alb"
  load_balancer_type = "application"

  subnet_mapping {
    subnet_id            = var.instance_list[0]["subnet_id"]
    private_ipv4_address = var.instance_list[0]["ip"]
  }

  subnet_mapping {
    subnet_id            = var.instance_list[1]["subnet_id"]
    private_ipv4_address = var.instance_list[1]["ip"]
  }
}

output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}
