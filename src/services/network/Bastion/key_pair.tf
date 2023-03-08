resource "tls_private_key" "keygen" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = "ec2-keypair"
  public_key = tls_private_key.keygen.public_key_openssh
}

resource "aws_kms_key" "secrets" {
  enable_key_rotation = true
}

resource "aws_secretsmanager_secret" "sample_key" {
  name       = "sample_key1"
  kms_key_id = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "sample_key" {
  secret_id     = aws_secretsmanager_secret.sample_key.id
  secret_string = tls_private_key.keygen.private_key_openssh
}

# aws secretsmanager get-secret-value --secret-id sample_key | jq -r .secretstring > id_ed25519
