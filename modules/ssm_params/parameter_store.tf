resource "aws_ssm_parameter" "db_username" {
  name        = "/wordpress/db_username"
  description = "Master username for WP db"
  type        = "SecureString"
  value       = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/wordpress/db_password"
  description = "Master password for WP db"
  type        = "SecureString"
  value       = var.db_password
}

output "username_path" {
  value = aws_ssm_parameter.db_username.name
}

output "password_path" {
  value = aws_ssm_parameter.db_password.name
}
