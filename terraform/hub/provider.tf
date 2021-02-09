terraform {
  
  # Terraform backend configuration
  backend "azurerm" {
    resource_group_name   = "terraform-backends"
    storage_account_name  = "terraform1612822914"
    container_name        = "hubandspokeaks"
    key                   = "aks/terraform.tfstate"
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