// Create azure resource group
resource "azurerm_resource_group" "this" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

// Create azure managed identity to be used by Databricks storage credential
resource "azurerm_databricks_access_connector" "db_mi" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

// Create a storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_account" "db_uc_catalog" {
  name                     = "${local.dlsprefix}acc"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  tags                     = azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

// Create a container in storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_container" "db_uc_catalog" {
  name                  = "${local.prefix}-catalog"
  storage_account_name  = azurerm_storage_account.db_uc_catalog.name
  container_access_type = "private"
}

// Assign the Storage Blob Data Contributor role to managed identity to allow unity catalog to access the storage
resource "azurerm_role_assignment" "mi_data_contributor" {
  scope                = azurerm_storage_account.db_uc_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.db_mi.identity[0].principal_id
}

// Create Databricks Storage Credential
resource "databricks_storage_credential" "external_mi" {
  name = "mi_credential"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.db_mi.id
  }
  comment = "Managed identity credential managed by TF"
}

// Create Databricks External Location
resource "databricks_external_location" "db_ext_loc" {
  name = "${local.prefix}-ext-loc"
  url = format("abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.db_uc_catalog.name,
  azurerm_storage_account.db_uc_catalog.name)
  credential_name = databricks_storage_credential.external_mi.id
  comment         = "Managed by TF"
  depends_on = [databricks_storage_credential.external_mi]
}

// Create Databricks Catalog
resource "databricks_catalog" "sandbox" {
  name         = var.catalog_name
  storage_root = format(
    "abfss://%s@%s.dfs.core.windows.net",
    azurerm_storage_container.db_uc_catalog.name,
  azurerm_storage_account.db_uc_catalog.name
  )
  # TODO: obviously this may not be ideal
  force_destroy = true
}