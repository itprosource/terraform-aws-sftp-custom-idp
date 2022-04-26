# s3 bucket and associated infrastructure
resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sftp" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.arn
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_kms_key" "key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}