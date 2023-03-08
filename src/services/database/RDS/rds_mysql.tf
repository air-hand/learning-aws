locals {
  db_name = "dbsample"
}

data "aws_vpc" "tf" {
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.tf.id]
  }

  tags = {
    Terraform = true
    private   = true
  }
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
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  multi_az               = false
  availability_zone      = var.az_name
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${local.db_name}-subnet-group"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Name = upper(local.db_name)
  }
}

resource "aws_security_group" "rds_security_group" {
  name   = "${local.db_name}-rds-security-group"
  vpc_id = data.aws_vpc.tf.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.tf.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.tf.cidr_block]
  }

  tags = {
    Name = upper(local.db_name)
  }
}
