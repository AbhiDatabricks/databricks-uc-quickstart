output "bucket_id" {
    value = module.infra.bucket_id
}

output "iam" {
  value = module.infra.role_ext_loc_arn
}