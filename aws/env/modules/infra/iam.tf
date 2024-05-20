data "aws_iam_policy_document" "uc_policy_doc_ext_loc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
      type        = "AWS"
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.storage_prefix}-ext-loc"]
    }
  }
}

resource "aws_iam_policy" "uc_policy_ext_loc" {
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.storage_prefix}-policy-ext-loc"
    Statement = [
      {
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          aws_s3_bucket.catalog_bucket.arn,
          "${aws_s3_bucket.catalog_bucket.arn}/*"
        ],
        "Effect" : "Allow"
      },
      {
        "Action" : [
          "sts:AssumeRole"
        ],
        "Resource" : [
          "arn:aws:iam::${var.aws_account_id}:role/${var.storage_prefix}-ext-loc"
        ],
        "Effect" : "Allow"
      }
    ]
  })
  tags = merge(var.tags, {
    Name = "${var.storage_prefix} IAM policy"
  })
}

resource "aws_iam_role" "uc_quickstart_ext_loc" {
  name                = "${var.storage_prefix}-ext-loc"
  assume_role_policy  = data.aws_iam_policy_document.uc_policy_doc_ext_loc.json
  managed_policy_arns = [aws_iam_policy.uc_policy_ext_loc.arn]
  tags = merge(var.tags, {
    Name = "${var.storage_prefix} IAM role"
  })
}