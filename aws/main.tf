module "dev_env" {
  source = "./env"

  providers = {
    aws = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_1}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_1}"

  external_location_name  = "${local.prefix}-${var.catalog_1}"

  catalog_name     = "${local.prefix}-${var.catalog_1}"

  storage_credential_name = ""
  storage_location_url = ""
  storage_root = ""
  iam_role_arn = ""
}

module "prod_env" {
  source = "./env"

  providers = {
    aws = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_2}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_2}"

  external_location_name  = "${local.prefix}-${var.catalog_2}"

  catalog_name     = "${local.prefix}-${var.catalog_2}"

  storage_credential_name = ""
  storage_location_url = ""
  storage_root = ""
  iam_role_arn = ""
}

module "sandbox_env" {
  source = "./env"

  providers = {
    aws = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_3}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_3}"

  external_location_name  = "${local.prefix}-${var.catalog_3}"

  catalog_name     = "${local.prefix}-${var.catalog_3}"

  storage_credential_name = ""
  storage_location_url = ""
  storage_root = ""
  iam_role_arn = ""
}