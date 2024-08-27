resource "aws_s3_bucket" "catalog_bucket" {
  bucket = "${var.bucket_name}"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.bucket_name}"
  })
}

resource "aws_s3_bucket_ownership_controls" "catalog_bucket_bucket_ownership_control" {
  bucket = aws_s3_bucket.catalog_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "catalog_bucket_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.catalog_bucket_bucket_ownership_control]

  bucket = aws_s3_bucket.catalog_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "catalog_bucket_bucket_versioning" {
  bucket = aws_s3_bucket.catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "catalog_bucket" {
  bucket                  = aws_s3_bucket.catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.catalog_bucket]
}