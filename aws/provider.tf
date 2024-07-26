terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "< 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  # profile = "default"
  # Use env variables for AWS creds if aws cli is not installed
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  # Include the aws_session_token if the temporary credential is used
  token = var.aws_session_token
}

// initialize provider at account level for provisioning workspace with AWS PrivateLink
provider "databricks" {
  # profile = "db-aws"
  host  = var.databricks_host
  token = var.databricks_token
}