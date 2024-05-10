
resource "databricks_storage_credential" "uc_storage_cred" {
#   provider = databricks.ws1
  name     = aws_iam_role.uc_quickstart_ext_loc.name
  aws_iam_role {
    role_arn = aws_iam_role.uc_quickstart_ext_loc.arn
  }
  comment = "Managed by TF"
}

resource "databricks_external_location" "uc_external_location" {
#   provider        = databricks.ws1
  name            = "uc_quickstart_ext_loc"
  url             = "s3://${aws_s3_bucket.dev_catalog.id}"
  credential_name = databricks_storage_credential.uc_storage_cred.id
  comment         = "Managed by TF"
}

# resource "databricks_grants" "some" {
# #   provider          = databricks.ws1
#   external_location = databricks_external_location.uc_external_location.id
#   grant {
#     principal  = "analyst"
#     privileges = ["CREATE_TABLE", "READ_FILES"]
#   }
# }