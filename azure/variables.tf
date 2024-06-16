locals {
  prefix = "uc-quickstart-${random_string.naming.result}"
  dlsprefix = "ucquickstart${random_string.naming.result}"
  tags = {
    project = "uc-quickstart"
  }
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "databricks_host" {}
variable "databricks_token" {}

# variable "databricks_account_id" {
#   description = "The Databricks Account ID"
#   type        = string
# }

variable "location" {
  description = "The Azure location"
  type        = string
  default     = "Australia East"
}

variable "catalog_name" {
  type        = string
  default     = "sandbox"
}
