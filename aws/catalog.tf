resource "databricks_catalog" "uc_quickstart_dev" {
  name    = "uc_quickstart_dev"
  storage_root = "${databricks_external_location.uc_external_location.url}dev"
  comment = "this catalog is managed by terraform"
  # enable_predictive_optimization = "ENABLE"
  # isolation_mode = "OPEN"
  properties = {
    purpose = "development"
  }
}

resource "databricks_catalog" "uc_quickstart_test" {
  name    = "uc_quickstart_test"
  storage_root = "${databricks_external_location.uc_external_location.url}test"
  comment = "this catalog is managed by terraform"
  # enable_predictive_optimization = "ENABLE"
  # isolation_mode = "OPEN"
  properties = {
    purpose = "testing"
  }
}

resource "databricks_catalog" "uc_quickstart_prod" {
  name    = "uc_quickstart_prod"
  storage_root = "${databricks_external_location.uc_external_location.url}prod"
  comment = "this catalog is managed by terraform"
  # enable_predictive_optimization = "ENABLE"
  # isolation_mode = "OPEN"
  properties = {
    purpose = "production"
  }
}

# resource "databricks_grants" "sandbox" {
#   provider = databricks.ws1
#   catalog  = databricks_catalog.sandbox.name
#   grant {
#     principal  = "account users" // account users
#     privileges = ["USAGE", "CREATE"]
#   }
# }