resource "time_sleep" "wait" {
  depends_on = [
    aws_iam_role.uc_quickstart_ext_loc
  ]
  create_duration = "10s"
}

resource "databricks_storage_credential" "uc_storage_cred" {
#   provider = databricks.ws1
  depends_on = [ aws_iam_role.uc_quickstart_ext_loc ]
  name     = aws_iam_role.uc_quickstart_ext_loc.name
  aws_iam_role {
    role_arn = aws_iam_role.uc_quickstart_ext_loc.arn
  }
  # aws_iam_role {
  #   role_arn = "${var.iam_role_arn}"
  # }
  comment = "Managed by TF"
}

resource "databricks_external_location" "uc_external_location" {
  depends_on = [ databricks_storage_credential.uc_storage_cred, aws_iam_role.uc_quickstart_ext_loc, time_sleep.wait ]
#   provider        = databricks.ws1
  # name            = "uc_quickstart_ext_loc"
  name = "${var.external_location_name}"
  url             = "s3://${aws_s3_bucket.catalog_bucket.id}"
  # url = "s3://${var.storage_location_url}"
  credential_name = databricks_storage_credential.uc_storage_cred.id
  comment         = "Managed by TF"
  force_destroy = true
}