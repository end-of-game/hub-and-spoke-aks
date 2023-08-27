terraform {
  
 # Terraform backend configuration
  backend "azurerm" {
    resource_group_name   = "rg-aks-apimprivate"
    storage_account_name  = "terraformbackendsstate"
    container_name        = "hubandspokeaks"
    key                   = "vault/terraform.tfstate"
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
    random = {
      source  = "random"
      version = "= 3.0.1"
    }
  }
}

# Initialize the azurerm provider
provider "azurerm" {
  features {}
}