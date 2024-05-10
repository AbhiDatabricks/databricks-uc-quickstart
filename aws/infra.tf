resource "aws_s3_bucket" "dev_catalog" {
  bucket = "${local.prefix}-catalog-dev"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-catalog-dev"
  })
}

resource "aws_s3_bucket_ownership_controls" "dev_catalog_bucket_ownership_control" {
  bucket = aws_s3_bucket.dev_catalog.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "dev_catalog_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.dev_catalog_bucket_ownership_control]

  bucket = aws_s3_bucket.dev_catalog.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "dev_catalog_bucket_versioning" {
  bucket = aws_s3_bucket.dev_catalog.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "dev_catalog" {
  bucket                  = aws_s3_bucket.dev_catalog.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.dev_catalog]
}

# # resource "aws_s3_bucket" "test_catalog" {
# #   bucket = "${local.prefix}-catalog-test"
# #   acl    = "private"
# #   versioning {
# #     enabled = false
# #   }
# #   force_destroy = true
# #   tags = merge(var.tags, {
# #     Name = "${local.prefix}-catalog-test"
# #   })
# # }

# # resource "aws_s3_bucket_public_access_block" "test_catalog" {
# #   bucket                  = aws_s3_bucket.test_catalog.id
# #   block_public_acls       = true
# #   block_public_policy     = true
# #   ignore_public_acls      = true
# #   restrict_public_buckets = true
# #   depends_on              = [aws_s3_bucket.test_catalog]
# # }

# # resource "aws_s3_bucket" "prod_catalog" {
# #   bucket = "${local.prefix}-catalog-prod"
# #   acl    = "private"
# #   versioning {
# #     enabled = false
# #   }
# #   force_destroy = true
# #   tags = merge(var.tags, {
# #     Name = "${local.prefix}-catalog-prod"
# #   })
# # }

# # resource "aws_s3_bucket_public_access_block" "prod_catalog" {
# #   bucket                  = aws_s3_bucket.prod_catalog.id
# #   block_public_acls       = true
# #   block_public_policy     = true
# #   ignore_public_acls      = true
# #   restrict_public_buckets = true
# #   depends_on              = [aws_s3_bucket.prod_catalog]
# # }