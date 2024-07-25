terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      configuration_aliases = [ databricks.account ]
    }
  }
}

// databricks at account level for account operations (groups)
provider "databricks" {
  alias                 = "account"
  host                  = "https://accounts.azuredatabricks.net"
  azure_client_id       = var.azure_client_id
  azure_client_secret   = var.azure_client_secret
  account_id            = var.databricks_account_id
  azure_tenant_id       = var.azure_tenant_id
}