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

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_groups             = var.sg_list
  key_name                    = var.bastion_key_name
  user_data                   = var.user_data
  associate_public_ip_address = var.associate_public_ip_address

  tags = {
    Name = var.ec2_name
  }
}


output "public_ip_addr" {
  value = aws_instance.ec2_instance.public_ip
}

output "public_dns" {
  value = aws_instance.ec2_instance.public_dns
}


output "private_ip" {
  value = aws_instance.ec2_instance.private_ip
}

output "instance_name" {
  value = aws_instance.ec2_instance.tags.Name
}
