module "infra" {
    source = "./modules/infra"
    providers = {
        aws = aws
    }
    databricks_account_id = var.databricks_account_id
    aws_account_id        = var.aws_account_id
    storage_prefix        = var.storage_prefix
    tags                  = var.tags
    bucket_name           = var.bucket_name
}

resource "time_sleep" "wait" {
  depends_on = [
    module.infra
  ]
  create_duration = "10s"
}

module "external_location" {
    source = "./modules/external_location"
    providers = {
        databricks = databricks
    }
    depends_on = [
      time_sleep.wait
    ]

    external_location_name  = var.external_location_name
    storage_credential_name = module.infra.role_ext_loc # aws_iam_role.uc_quickstart_ext_loc.name
    storage_location_url    = module.infra.bucket_id # "s3://${aws_s3_bucket.dev_catalog.id}"
    iam_role_arn            = module.infra.role_ext_loc_arn # aws_iam_role.uc_quickstart_ext_loc.arn
}

module "catalog" {
  source           = "./modules/catalog"
  providers = {
    databricks = databricks
  }
  depends_on       = [ module.external_location ]

  catalog_name     = var.catalog_name
  storage_root     = "s3://${module.infra.bucket_id}/data" # databricks_external_location.uc_external_location.url + storage_path
}

module "public_preview_system_table" {
  source = "./modules/system_schema/"
  providers = {
    databricks = databricks
  }
}

# module "grant" {
#   source = "./modules/grant"
#   providers = {
#     databricks = databricks
#   }
# depends_on = [ module.catalog]
# catalog_name = var.catalog_name
# permissions  = var.permissions
# }