terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host          = var.databricks_host
  client_id     = var.client_id
  client_secret = var.client_secret
}