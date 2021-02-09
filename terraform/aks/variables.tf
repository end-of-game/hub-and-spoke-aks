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
  default = "aks"
}
variable "default_tags" {
  type = map
  default = {
    Project     = "hub-and-spoke"
    Application = "aks"
    Automate    = "terraform"
    Customer    = "all"
  }
}
data "azurerm_client_config" "current" {}
data "azurerm_key_vault" "vault" {
  name                = "${var.project}-vault"
  resource_group_name = "${var.project}-vault"
}

# Project variables
# ------------------------------------
variable "vnet_cidr" {
  type = map
  default = {
    "dev"    = "10.1.0.0/16" 
    "test"   = "10.2.0.0/16"
    "prod"   = "10.3.0.0/16"
  }
}
variable "aks_node_pool_cidr" {
  type = map
  default = {
    "dev"      = "10.1.0.0/17"
    "staging"  = "10.2.0.0/17"
    "prod"     = "10.3.0.0/17"
  }
}
variable "aks_max_pod_number" {
  type    = map
  default = {
    "dev"    = 100
    "test"   = 100
    "prod"   = 100
  }
}
variable "node_count" {
  type = map
  default = {
    "dev"    = 1
    "test"   = 1
    "prod"   = 2
  }
}
variable "node_size" {
  type = map
  default = {
    "dev"    = "standard_ds3_v2" # 4vCPUs, 14GiB
    "test"   = "standard_ds3_v2" # 4vCPUs, 14GiB
    "prod"   = "standard_ds3_v2" # 4vCPUs, 14GiB
  }
}
variable "ssh_pub_key_secret_name" {
  type = map
  default = {
    "dev"       = "aks-dev-ssh-pub"
    "staging"   = "aks-test-ssh-pub"
    "prod"      = "aks-prod-ssh-pub"
  }
}
variable "aks_ingress_lb_ip" {
  type = map
  default = {
    "dev"    = "10.1.127.200"
    "test"   = "10.2.127.200"
    "prod"   = "10.3.127.200"
  }
}
variable "end_date" {
  default = "2023-01-01T01:02:03Z"
}
variable "node_admin_username" {
  type    = string
  default = "ubuntu"
}

# Environment variables
# Dynamic because of workspace usage
# ------------------------------------
locals {
  environment = terraform.workspace
  stack_name  = "${var.project}-${var.application}-${terraform.workspace}"

  # Local variables prefixed with 'env_' are environment dependant
  env_tags                    = merge(var.default_tags, map("Environment", local.environment))
  env_vnet_cidr               = lookup(var.vnet_cidr, terraform.workspace)
  env_node_count              = lookup(var.node_count, terraform.workspace)
  env_node_size               = lookup(var.node_size, terraform.workspace)
  env_aks_node_pool_cidr      = lookup(var.aks_node_pool_cidr, terraform.workspace)
  env_aks_ingress_lb_ip       = lookup(var.aks_ingress_lb_ip, terraform.workspace)
  env_ssh_pub_key_secret_name = lookup(var.ssh_pub_key_secret_name, terraform.workspace)
  env_aks_max_pod_number      = lookup(var.aks_max_pod_number, terraform.workspace)
}
