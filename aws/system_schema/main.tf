// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/system_schema

resource "databricks_system_schema" "access" {
  provider     = databricks
  schema = "access"
}

resource "databricks_system_schema" "billing" {
  provider     = databricks
  schema = "billing"
}

resource "databricks_system_schema" "compute" {
  provider     = databricks
  schema = "compute"
}

resource "databricks_system_schema" "workflow" {
  provider     = databricks
  schema = "workflow"
}

resource "databricks_system_schema" "marketplace" {
  provider     = databricks
  schema = "marketplace"
}

resource "databricks_system_schema" "storage" {
  provider     = databricks
  schema = "storage"
}
