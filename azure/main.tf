module "sandbox_catalog" {
  source = "./modules/env"

  providers = {
    azurerm = azurerm
    databricks = databricks
  }

  access_connector_id     = ""
  access_connector_name   = "${local.prefix}-${var.catalog_1}-databricks-mi"
  resource_group          = var.resource_group
  location                = var.location
  storage_account_name    = "${local.dlsprefix}${var.catalog_1}acc"
  tags                    = local.tags
  storage_container_name  = "${local.prefix}-${var.catalog_1}"

  storage_credential_name = "${local.prefix}-${var.catalog_1}"
  external_location_name  = "${local.prefix}-${var.catalog_1}"
  
  catalog_name            = "${local.prefix}-${var.catalog_1}"
}

module "dev_catalog" {
  source = "./modules/env"

  providers = {
    azurerm = azurerm
    databricks = databricks
  }

  access_connector_id     = ""
  access_connector_name   = "${local.prefix}-${var.catalog_2}-databricks-mi"
  resource_group          = var.resource_group
  location                = var.location
  storage_account_name    = "${local.dlsprefix}${var.catalog_2}acc"
  tags                    = local.tags
  storage_container_name  = "${local.prefix}-${var.catalog_2}"

  storage_credential_name = "${local.prefix}-${var.catalog_2}"
  external_location_name  = "${local.prefix}-${var.catalog_2}"
  
  catalog_name            = "${local.prefix}-${var.catalog_2}"
}

module "prod_catalog" {
  source = "./modules/env"

  providers = {
    azurerm = azurerm
    databricks = databricks
  }

  access_connector_id     = ""
  access_connector_name   = "${local.prefix}-${var.catalog_3}-databricks-mi"
  resource_group          = var.resource_group
  location                = var.location
  storage_account_name    = "${local.dlsprefix}${var.catalog_3}acc"
  tags                    = local.tags
  storage_container_name  = "${local.prefix}-${var.catalog_3}"

  storage_credential_name = "${local.prefix}-${var.catalog_3}"
  external_location_name  = "${local.prefix}-${var.catalog_3}"
  
  catalog_name            = "${local.prefix}-${var.catalog_3}"
}