terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

// databricks at account level for account operations (groups)
provider "databricks" {
  alias         = "account"
  host          = "https://accounts.azuredatabricks.net"
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret
  account_id    = var.databricks_account_id
}