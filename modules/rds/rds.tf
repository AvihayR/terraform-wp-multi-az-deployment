resource "aws_db_instance" "wp-rds-db" {
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.rds-sb-gr.name
  allocated_storage      = 10
  db_name                = var.db_name
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro"
  username               = var.username
  password               = var.password
  vpc_security_group_ids = var.sg_id_list
  #   parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "rds-sb-gr" {
  name       = "wp-db-subnet-group"
  subnet_ids = var.rds_subnet_group
}

output "endpoint" {
  value = aws_db_instance.wp-rds-db.address
}
