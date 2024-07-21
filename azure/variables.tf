locals {
  prefix = "ucqs-${random_string.naming.result}"
  dlsprefix = "ucqs${random_string.naming.result}"
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

variable "resource_group" {
  description = "The Azure resource group name"
  type        = string
}

variable "databricks_host" {}
variable "databricks_token" {}

variable "location" {
  description = "The Azure location"
  type        = string
  default     = "Australia East"
}


#############
# Configure catalog names to deploy
variable "catalog_1" {
  type        = string
  default     = "sandbox"
}

variable "catalog_2" {
  type        = string
  default     = "dev"
}

variable "catalog_3" {
  type        = string
  default     = "prod"
}
