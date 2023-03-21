locals {
  db_name = "dbsample"
}

#tfsec:ignore:aws-rds-encrypt-instance-storage-data
resource "aws_db_instance" "rds_mysql" {
  identifier             = local.db_name
  allocated_storage      = 5
  instance_class         = "db.t3.micro"
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  username               = "user"
  password               = aws_secretsmanager_secret_version.db_pass.secret_string
  db_name                = local.db_name
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
  apply_immediately      = true
  vpc_security_group_ids = [aws_security_group.mysql_security_group.id]
  multi_az               = false
  availability_zone      = var.az_name
}
