resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.tls_key.public_key_openssh
}

resource "local_file" "save_key_pair" {
  filename        = "${var.key_name}.pem"
  content         = tls_private_key.tls_key.private_key_pem
  file_permission = "0600"
}

output "key_pair" {
  value = aws_key_pair.generated_key_pair
}
