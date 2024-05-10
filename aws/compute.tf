# resource "databricks_sql_endpoint" "warehouse" {
#   name             = "renji-ucq-sqlwh"
#   cluster_size     = "2X-Small"
#   max_num_clusters = 1
#   auto_stop_mins   = 15
#   # warehouse_type   = "PRO"

#   tags {
#     custom_tags {
#       key   = "project"
#       value = "ucq"
#     }
#   }
# }

# output "sql_warehouse_id" {
#   value       = databricks_sql_endpoint.warehouse.data_source_id
#   description = "POC Accelerate SQL Warehouse ID"
# }