resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name
  force_destroy = true
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        #kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  tags = {
    Name        = var.bucket_name
  }
}
