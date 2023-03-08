output "kms_key_alias" {
  value = aws_kms_alias.mykey.name
}
