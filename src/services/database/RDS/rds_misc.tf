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

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = data.aws_subnets.private.ids
}

# TODO: delete
# terraform state mv ...aws_db_subnet_group.rds_subnet_group ...aws_dub_subnet_group.tmp_subnet_group
resource "aws_db_subnet_group" "tmp_subnet_group" {
  name       = "dbsample-subnet-group"
  subnet_ids = data.aws_subnets.private.ids
}

# TODO: delete
resource "aws_security_group" "rds_security_group" {
  name   = "dbsample-rds-security-group"
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
}

resource "aws_security_group" "mysql_security_group" {
  name   = "mysql-security-group"
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
}
