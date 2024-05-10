# resource "databricks_schema" "cyber_datasets" {
#   catalog_name = databricks_catalog.uc_quickstart_prod.id
#   name         = "datasets"
#   comment      = "Cybersecurity-related datasets"
#   storage_root = "${databricks_external_location.cybersecurity.url}datasets"
# }

# resource "databricks_grants" "things" {
#   provider = databricks.ws1
#   schema   = databricks_schema.things.id
#   grant {
#     principal  = "account users"
#     privileges = ["USAGE", "CREATE"]
#   }
# }