terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
    }
  }
}

// databricks at account level for account operations (groups)
provider "databricks" {
  # alias         = "account"
  host          = "https://accounts.cloud.databricks.com"
  client_id     = var.client_id
  client_secret = var.client_secret
  account_id    = var.databricks_account_id
}