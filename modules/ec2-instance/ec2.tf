data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["arm64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "wp_ec2_instance" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  subnet_id       = var.subnet_id
  security_groups = var.sg_list
  key_name        = var.bastion_key_name
  # --- temporary ---- #
  associate_public_ip_address = true

  tags = {
    Name = "wp-instance"
  }
}


output "public_ip_addr" {
  value = aws_instance.wp_ec2_instance.public_ip
}

output "public_dns" {
  value = aws_instance.wp_ec2_instance.public_dns
}
