provider "azurerm" {
  skip_provider_registration = true
  features {}
  # subscription_id = var.subscription_id
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

#Authenticating with Azure-managed Service Principal
provider "databricks" {
  host                        = var.databricks_host
  azure_workspace_resource_id = var.databricks_resource_id
  azure_client_id             = var.azure_client_id
  azure_client_secret         = var.azure_client_secret
  azure_tenant_id             = var.azure_tenant_id
}