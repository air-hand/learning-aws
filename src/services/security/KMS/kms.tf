resource "aws_kms_key" "mykey" {
  enable_key_rotation = true
}

resource "aws_kms_alias" "mykey" {
  name          = "alias/my-key"
  target_key_id = aws_kms_key.mykey.id
}
