output "role_ext_loc" {
  value = aws_iam_role.uc_quickstart_ext_loc.name
}

output "role_ext_loc_arn" {
    value = aws_iam_role.uc_quickstart_ext_loc.arn
}

output "bucket_id" {
    value = aws_s3_bucket.catalog_bucket.id
}