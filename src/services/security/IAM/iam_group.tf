resource "aws_iam_group" "developers" {
  name = "developers"
  path = "/users/"
}

resource "aws_iam_group" "operators" {
  name = "operators"
  path = "/users/"
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "read-policy" {
  name = "test-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S3ReadPermitted"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:GetObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::*",
        ]
      }
    ]
  })
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "put-policy" {
  name = "test-policy-2"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "S3Put"
        Action = [
          "s3:PutObject",
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::*",
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "dev-policy-attach1" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.read-policy.arn
}

resource "aws_iam_group_policy_attachment" "dev-policy-attach2" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.put-policy.arn
}

resource "aws_iam_group_policy_attachment" "op-policy-attach1" {
  group      = aws_iam_group.operators.name
  policy_arn = aws_iam_policy.read-policy.arn
}
