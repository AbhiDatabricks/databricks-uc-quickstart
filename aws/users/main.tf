resource "databricks_group" "account_group" {
  provider     = databricks.account
  display_name = var.group_name
  workspace_access = true
}


resource "databricks_permission_assignment" "this" {
  principal_id = resource.databricks_group.account_group.id
  permissions  = ["USER"]
  provider     = databricks.workspace
}

