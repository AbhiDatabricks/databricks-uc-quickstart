resource "time_sleep" "wait" {
  create_duration = "20s"
}

resource "databricks_grants" "this" {
  catalog = var.catalog_name
  grant {
    principal  = var.group_1_name
    privileges = var.permissions["group_1"]
  }
  grant {
    principal  = var.group_2_name
    privileges = var.permissions["group_2"]
  }
  grant {
    principal  = var.group_3_name
    privileges = var.permissions["group_3"]
  }
}

data "databricks_catalog" "system_catalog" {
  name = "system"
}

data "databricks_schemas" "system_schemas" {
  catalog_name = "system"
}

resource "databricks_grant" "system_catalog" {
  catalog = data.databricks_catalog.system_catalog.name
  principal  = var.group_1_name
  privileges = ["USE_CATALOG"]
}

resource "databricks_grant" "system_schemas" {
  for_each = toset(data.databricks_schemas.system_schemas.ids)
  schema = "${each.key}"
  principal  = var.group_1_name
  privileges = ["USE_SCHEMA", "SELECT"]
}
