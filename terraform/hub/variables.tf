# Global variables
# --------------------------

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
  default = "hub"
}
variable "default_tags" {
  type = map
  default = {
    Project     = "hub-and-spoke"
    Application = "hub"
    Automate    = "terraform"
    Customer    = "all"
    Environment = "common"
  }
}
variable "end_date" {
  default = "2023-01-01T01:02:03Z"
}
data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "vault" {
  name                = "${var.project}-vault"
  resource_group_name = "${var.project}-vault"
}

# Project variables
# --------------------------

# Network
variable "vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
  # 100.0.0.0 - 100.0.255.255
}
variable "subnet_waf_cidr" {
  type    = string
  default = "10.0.0.0/22"
  # 100.0.0.0 - 100.0.3.255
}
variable "subnet_management_cidr" {
  type    = string
  default = "10.0.4.0/22"
}
# The name corresponds to both vnet name and resource group name
variable "vnet_spoke_to_peer" {
  type = list
  default = [
    "hub-and-spoke-aks-dev",
  ]
}
variable "aks_private_lb_ip" {
  type = map
  default = {
    "dev"       = "10.1.127.200"
    "staging"   = "10.2.127.200"
    "prod"      = "10.3.127.200"
  }
}
variable "domain" {
  type    = string
  default = "linkbynet.com"
}
variable "exposed_dns" {
  type = map
  default = {
    "app-dev" = {
      "dns"       = "dev.linkbynet.com"
      "env"       = "dev"
      "protocol" = "Http"
    }
  }
}
variable "certificate_wildcard_name_in_vault" {
  type    = string 
  default = "wildcard-linkbynet-com"
}

# Local variables
# --------------------------
locals {
  stack_name = "${var.project}-${var.application}"
}
