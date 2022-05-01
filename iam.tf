resource "aws_iam_role" "sftp_role" {
  name = "custom_idp_sftp_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "transfer.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "sftp" {
  name        = "custom-idp-sftp"
  description = "s3 access policy for custom identities"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowListingOfUserFolder",
        "Action": [
          "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
          "${aws_s3_bucket.s3.arn}"
        ]
      },
      {
        "Sid": "HomeDirObjectAccess",
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObjectVersion",
          "s3:GetObjectACL",
          "s3:PutObjectACL"
        ],
        "Resource": "${aws_s3_bucket.s3.arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "sftp-attach" {
  name       = "sftp-attachment"
  roles      = [aws_iam_role.sftp_role.name]
  policy_arn = aws_iam_policy.sftp.arn
}

resource "aws_iam_policy" "secrets" {
  name        = "custom-idp-secrets"
  description = "Secrets Mgr policy allowing access for SFTP server"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "secretsmanager:GetSecretValue"
        ],
        "Resource": "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:SFTP/*",
        "Effect": "Allow"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "secrets-attach" {
  name       = "secrets-attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.secrets.arn
}
