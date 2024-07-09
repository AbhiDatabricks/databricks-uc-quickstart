terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      configuration_aliases = [ databricks.account, databricks.workspace]
    }
  }
}

// databricks at account level for account operations (groups)
provider "databricks" {
  alias         = "account"
  host          = "https://accounts.cloud.databricks.com"
  client_id     = var.client_id
  client_secret = var.client_secret
  account_id    = var.databricks_account_id
}

// databricks at workspace level 
provider "databricks" {
  alias         = "workspace"
  host          = var.databricks_host
  client_id     = var.client_id
  client_secret = var.client_secret
}