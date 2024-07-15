provider "azurerm" {
  skip_provider_registration = true
  features {}
#   subscription_id = var.subscription_id
}

# provider "azapi" {
#   subscription_id = var.subscription_id
# }

# provider "databricks" {
#   alias      = "account"
#   host       = "https://accounts.azuredatabricks.net"
#   account_id = var.databricks_account_id
#   auth_type  = "azure-cli"
# }

provider "databricks" {
  host = var.databricks_host
  token = var.databricks_token
}
