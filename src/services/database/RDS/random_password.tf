resource "random_password" "db_pass" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "db_pass" {
  name = "${var.db_name}-pass"
}

resource "aws_secretsmanager_secret_version" "db_pass" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = random_password.db_pass.result
}

# aws secretsmanager get-secret-value --secret-id rds-sample_db_pass | jq -r .SecretString
