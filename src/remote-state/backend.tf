terraform {
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "local" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

resource "aws_kms_key" "mykey" {
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encrypt" {
  bucket = aws_s3_bucket.tf_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tf_state" {
  bucket = aws_s3_bucket.tf_state.bucket
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#
#resource "aws_s3_bucket_acl" "tf_state" {
#  bucket = aws_s3_bucket.tf_state.id
#  acl    = "private"
#}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_state_lc" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    id = "rule-tf-state"

    filter {
      prefix = replace(var.key, "/\\/.+$/", "/")
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 5
      noncurrent_days = 30
    }
    status = "Enabled"
  }
}

#
#resource "aws_s3_bucket_acl" "tf_state" {
#  bucket = aws_s3_bucket.tf_state.id
#  acl    = "private"
#}

resource "aws_s3_bucket_logging" "tf_state" {
  bucket = aws_s3_bucket.tf_state.bucket

  target_bucket = aws_s3_bucket.tf_state.bucket
  target_prefix = "log/"
}

resource "aws_dynamodb_table" "tf_state_lock" {
  name           = var.dynamodb_table
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.mykey.arn
  }

  point_in_time_recovery {
    enabled = true
  }
}

