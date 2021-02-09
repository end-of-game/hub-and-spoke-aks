# Global variables
# ------------------------------------

variable "location" {
  type    = string
  default = "francecentral"
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
    "79f9fdc8-fa4c-43d9-85a9-d0860ab6f463",
  ]
}

# Local variables
# ------------------------------------
locals {
  stack_name  = "${var.project}-${var.application}"
}
