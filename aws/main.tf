

//create the groups and assign to the workspace



module "prod_sp_group" {
  source                = "./users"
  group_name            = "${local.prefix}-${var.group_1}"
  databricks_account_id = var.databricks_account_id
  databricks_host       = var.databricks_host
  # databricks_account_username = var.databricks_account_username
  # databricks_account_password = var.databricks_account_password
  client_id               = var.databricks_client_id
  client_secret           = var.databricks_client_secret
  databricks_workspace_id = var.databricks_workspace_id
}

module "developers_group" {
  source                = "./users"
  group_name            = "${local.prefix}-${var.group_2}"
  databricks_account_id = var.databricks_account_id
  databricks_host       = var.databricks_host
  # databricks_account_username = var.databricks_account_username
  # databricks_account_password = var.databricks_account_password
  client_id               = var.databricks_client_id
  client_secret           = var.databricks_client_secret
  databricks_workspace_id = var.databricks_workspace_id
}

module "sandbox_users_group" {
  source                = "./users"
  group_name            = "${local.prefix}-${var.group_3}"
  databricks_account_id = var.databricks_account_id
  databricks_host       = var.databricks_host
  # databricks_account_username = var.databricks_account_username
  # databricks_account_password = var.databricks_account_password
  client_id               = var.databricks_client_id
  client_secret           = var.databricks_client_secret
  databricks_workspace_id = var.databricks_workspace_id
}




// create the catalogs and infrastructure
module "dev_env" {
  source = "./env"

  providers = {
    aws        = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_1}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_1}"

  external_location_name = "${local.prefix}-${var.catalog_1}"

  catalog_name = "${local.prefix}-${var.catalog_1}"

  storage_credential_name = ""
  storage_location_url    = ""
  storage_root            = ""
  iam_role_arn            = ""
}

module "prod_env" {
  source = "./env"

  providers = {
    aws        = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_2}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_2}"

  external_location_name = "${local.prefix}-${var.catalog_2}"

  catalog_name = "${local.prefix}-${var.catalog_2}"

  storage_credential_name = ""
  storage_location_url    = ""
  storage_root            = ""
  iam_role_arn            = ""
}

module "sandbox_env" {
  source = "./env"

  providers = {
    aws        = aws
    databricks = databricks
  }
  databricks_account_id = var.databricks_account_id
  aws_account_id        = var.aws_account_id
  storage_prefix        = "${local.prefix}-${var.catalog_3}"
  tags                  = var.tags
  bucket_name           = "${local.prefix}-${var.catalog_3}"

  external_location_name = "${local.prefix}-${var.catalog_3}"

  catalog_name = "${local.prefix}-${var.catalog_3}"

  storage_credential_name = ""
  storage_location_url    = ""
  storage_root            = ""
  iam_role_arn            = ""
}


// Grant privileges

module "grant_prod" {
  source       = "./grant"
  catalog_name = "${local.prefix}-${var.catalog_1}"
  permissions  = var.catalog_1_permissions
  group_1_name = "${local.prefix}-${var.group_1}"
  group_2_name = "${local.prefix}-${var.group_2}"
  group_3_name = "${local.prefix}-${var.group_3}"
  depends_on   = [module.sandbox_users_group, module.developers_group, module.prod_sp_group, module.prod_env]
}

module "grant_dev" {
  source       = "./grant"
  catalog_name = "${local.prefix}-${var.catalog_2}"
  permissions  = var.catalog_2_permissions
  group_1_name = "${local.prefix}-${var.group_1}"
  group_2_name = "${local.prefix}-${var.group_2}"
  group_3_name = "${local.prefix}-${var.group_3}"
  depends_on   = [module.sandbox_users_group, module.developers_group, module.prod_sp_group, module.dev_env]
}


module "grant_sandbox" {
  source       = "./grant"
  catalog_name = "${local.prefix}-${var.catalog_3}"
  permissions  = var.catalog_3_permissions
  group_1_name = "${local.prefix}-${var.group_1}"
  group_2_name = "${local.prefix}-${var.group_2}"
  group_3_name = "${local.prefix}-${var.group_3}"
  depends_on   = [module.sandbox_users_group, module.developers_group, module.prod_sp_group, module.sandbox_env]
}
