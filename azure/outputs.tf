output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "rg_location" {
  value = azurerm_resource_group.this.location
}

output "storage_account" {
    value = azurerm_storage_account.db_uc_catalog.name
}

output "storage_container" {
    value = azurerm_storage_container.db_uc_catalog.name
}

output "access_connected_id" {
    value = azurerm_databricks_access_connector.db_mi.id
}

