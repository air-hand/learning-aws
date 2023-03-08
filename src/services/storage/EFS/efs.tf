# One-Zone

#tfsec:ignore:aws-efs-enable-at-rest-encryption
resource "aws_efs_file_system" "efs" {
  availability_zone_name = var.az_name
}
