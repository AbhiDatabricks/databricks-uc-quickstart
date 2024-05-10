resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "uc-quickstart-${random_string.naming.result}"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Optional tags to add to created resources"
}

# variable "databricks_account_username" {}
# variable "databricks_account_password" {}
variable "databricks_account_id" {}
variable "databricks_host" {}
variable "databricks_token" {}

variable "region" {
  default = "ap-southeast-2"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}