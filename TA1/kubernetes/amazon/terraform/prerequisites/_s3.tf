resource "aws_s3_bucket" "tf-hybrid-kong" {
    bucket = "tf-hybrid-kong-bucket"
    acl = "private"
    # Prevent accidental deletion of this S3 bucket
    lifecycle {
      prevent_destroy = true
    }
    tags{
      Name = "tf-hybrid-kong-bucket"
    }
}

resource "aws_s3_bucket_versioning" "tf-hybrid-kong-versioning" {
  bucket = aws_s3_bucket.tf-hybrid-kong.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.tf-hybrid-kong.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.tf-hybrid-kong.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}