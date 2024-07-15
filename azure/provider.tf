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

# provider "databricks" {
#   alias                       = "workspace"
#   azure_workspace_resource_id = module.databricks_workspace.databricks_workspace_resid
#   host = var.databricks_host
#   token = var.databricks_token
# }

#OAuth M2M authentication
provider "databricks" {
  alias = "workspace"
  host = var.databricks_host
  client_id = var.databricks_client_ID
  client_secret = var.databricks_client_secret
}