resource "databricks_catalog" "uc_quickstart" {
  name    = "${var.catalog_name}"
  storage_root = "${var.storage_root}"
  comment = "this catalog is managed by terraform"
  # enable_predictive_optimization = "ENABLE"
  # isolation_mode = "OPEN"
  # properties = {
  #   purpose = "development"
  # }
}

# resource "databricks_grants" "sandbox" {
#   provider = databricks.ws1
#   catalog  = databricks_catalog.sandbox.name
#   grant {
#     principal  = "account users" // account users
#     privileges = ["USAGE", "CREATE"]
#   }
# }