# Deploy multiple catalogs in Databricks UC

## 1. **Configure TFVAR file**

Create a tfvar file and name it `db.tffvar`

Copy below configurations and replace with relevant entries

```
databricks_account_id = "XX"
databricks_host       = "https://XX.com"
databricks_token      = "XX"

# AWS credentials
aws_access_key = "XX"
aws_secret_key = "XX/2KU3AYaueBzfJQeiXFqhE6"
aws_account_id = "1234567890"

```

Note: AWS and Databricks creds can be injected as environment variables if required. Approach adopted here is for ease of switching environments while testing.

## 2. **Provide expected catalog names as input**

Go to the `main.tf` file. Here you can see 3 entries of env module will be executed.

```
module "dev_env" {
...
}

module "prod_env" {
...
}

module "sandbox_env" {
...    
}

```
By default 3 catalogs (and associated DB and AWS entities) will get deployed:
- dev
- prod
- sandbox

If you need to change the catalog names, navigate to the `variables.tf` in the root directory and update the values given against catalog_1, catalog_2 or catalog_3.

```
variable catalog_1 {
  default = "dev"
}

variable catalog_2 {
  default = "prod"
}

variable catalog_3 {
  default = "sandbox"
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