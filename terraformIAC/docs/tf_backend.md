# Terraform backend

The backend can be provision with Terraform, but the corresponding state file will not be stored in a share storage. On the other hand it is created once and rarely needs to be modified. So, we will create it manually with Azure CLI.

## Create account storage with Azure CLI

Eventually adapt the variables in the script [backend.sh](../scripts/backend.sh) and execute it.

> Note the name of your storage account and the associated access key, you will need it later.

## Configure the backend in Terraform

Export the storage access key as environment variable in order that Terraform can use it:

```bash
export ARM_ACCESS_KEY=<storage access key>
```

Configure the backend in the `provider.tf` file:

```hcl
terraform {
  
  # Terraform backend configuration
  backend "azurerm" {
    resource_group_name   = "terraform-backends"
    storage_account_name  = "terraform1612822914"
    container_name        = "hubandspokeaks"
    key                   = "terraform.tfstate"
  }

  # List required providers with version constraints
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "= 2.45.1"
    }
    azuread = {
      source  = "azuread"
      version = "= 1.3.0"
    }
  }
}

# Initialize the azurerm provider
provider "azurerm" {
  features {}
}
```

And test that everything is working:

```bash
$ terraform init

Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/azuread versions matching "1.3.0"...
- Finding hashicorp/azurerm versions matching "2.45.1"...
- Installing hashicorp/azuread v1.3.0...
- Installed hashicorp/azuread v1.3.0 (signed by HashiCorp)
- Installing hashicorp/azurerm v2.45.1...
- Installed hashicorp/azurerm v2.45.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```
