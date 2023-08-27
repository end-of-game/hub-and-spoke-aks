# Global variables
# ------------------------------------

variable "location" {
  type    = string
  default = "westus2"
}
variable "project" {
  type    = string
  default = "hub-and-spoke"
}
variable "application" {
  type    = string
  default = "vault"
}
variable "default_tags" {
  type = map
  default = {
    Project     = "hub-and-spoke"
    Application = "vault"
    Automate    = "terraform"
    Customer    = "all"
  }
}
data "azurerm_client_config" "current" {}


# Project variables
# ------------------------------------
variable "azure_administrator_object_id" {
  type = list
  default = [
    "fda24d3f-ad67-4fb3-a776-e0bd1e8b4720",
  ]
}

# Local variables
# ------------------------------------
locals {
  stack_name  = "${var.project}-${var.application}"
}
