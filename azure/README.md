### Prerequisites

1. **Microsoft Resource Providers**
- Microsoft.Databricks
- Microsoft.Storage
- Microsoft.ManagedIdentity

2. **Service Principal Permissions**
- Contributor - Azure Subscription
- Account Admin - Databricks Account Portal

3. **Existing Resources**
- Azure Databricks workspace
- Resource Group for Access Connectors & Storage Accounts

# Deploy multiple catalogs in Databricks UC

## 1. **Configure TFVAR file**

Copy the file `template.tfvars.example` and name it `db.tffvar`

Update the configuration with the relavant entries:

```
# Databricks Environment Variables
databricks_account_id    = "" // Your Azure Databricks Account ID
databricks_workspace_id  = "" // The Azure Databricks workspace ID e.g. "adb-{workspace_id}.x.azuredatabricks.net"

# Common Authentication Variables
databricks_host          = "" // The URL of the workspace e.g "adb-xxxxxxxxxxxxxxx.x.azuredatabricks.net"

# PAT Token Authentication Credentials
databricks_token         = "" // The personal access token to provision the resources in the Databricks workspace

# Azure-Managed Service Principal credentials
databricks_resource_id   = "" // Specifies the resource ID of the Databricks workspace e.g /subscriptions/{subscription_id}/resourceGroups/{resource_group}/providers/Microsoft.Databricks/workspaces/{workspace_name}
azure_client_id          = "" // Specifies the Application ID of the service principal
azure_client_secret      = "" // Specifies a client secret associated with the service principal
azure_tenant_id          = "" // The Azure Tenant ID the service principal resides in

# Azure Resources
resource_group           = "" // The resource group where storage accounts & access connectors will be deployed to

```

Note: Azure and Databricks credentials can be injected as environment variables if required. Approach adopted here is for ease of switching environments while testing.

## 2. **Provide expected catalog names as input**

Go to the `main.tf` file. Here you can see 3 entries of env module will be executed.

```
module "sandbox_catalog" {
...
}

module "dev_catalog" {
...
}

module "prod_catalog" {
...    
}

```
By default 3 catalogs (and associated DB and Azure entities) will get deployed:
- sandbox
- dev
- prod
and 3 groups will be created: 
- production_sp
- developers
- sandbox users 

If you need to change the catalog or group names, navigate to the `variables.tf` in the root directory and update the values given against catalog_1, catalog_2 or catalog_3.

```
variable catalog_1 {
  default = "sandbox"
}

variable catalog_2 {
  default = "dev"
}

variable catalog_3 {
  default = "prod"
}

variable "group_1" {
  default = "production_sp"
}

variable "group_2" {
  default = "developers"
}

variable "group_3" {
  default = "sandbox_users"
}



variable "catalog_1_permissions" {
  type = map(list(string))
  default = {
    group_1 = ["ALL_PRIVILEGES"]
    group_2 = ["USE_CATALOG", "SELECT"]
    group_3 = []
  }
}

variable "catalog_2_permissions" {
  type = map(list(string))
  default = {
    group_1 = ["ALL_PRIVILEGES"]
    group_2 = ["ALL_PRIVILEGES"]
    group_3 = []
  }
}

variable "catalog_3_permissions" {
  type = map(list(string))
  default = {
    group_1 = ["ALL_PRIVILEGES"]
    group_2 = ["ALL_PRIVILEGES"]
    group_3 = ["ALL_PRIVILEGES"]
  }
}
```

## 3. **Deploy**

Run below commands in sequence to provision the catalogs

```
terraform init
terraform validate
terraform plan -var-file="db.tfvars"
terraform apply -var-file="db.tfvars" -auto-approve
```