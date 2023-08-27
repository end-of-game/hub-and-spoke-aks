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
  name                = "vaultspokevituity"
  resource_group_name = "${var.project}-vault"
}

# Project variables
# ------------------------------------
variable "vnet_cidr" {
  description = "A map of VNet CIDRs for each environment."
  type        = map(string)
  default = {
    default = "10.0.0.0/8"
    dev     = "10.0.0.0/8"
    staging    = "10.250.0.0/16"
    prod    = "10.230.0.0/16"
  }
}
variable "aks_node_pool_cidr" {
  type = map
  default = {
    "default"  = "10.240.0.0/16"
    "dev"      = "10.240.0.0/16"
    "staging"  = "10.250.0.0/22"
    "prod"     = "10.230.0.0/22"
  }
}
variable "aks_max_pod_number" {
  type    = map
  default = {
    default  = 100
    "dev"    = 100
    "staging"   = 100
    "prod"   = 100
  }
}
variable "node_count" {
  type = map
  default = {
    default  = 2
    "dev"    = 2
    "staging"   = 2
    "prod"   = 3
  }
}
variable "node_size" {
  type = map
  default = {
    default  = "standard_d4ads_v5" # 4vCPUs, 14GiB
    "dev"    = "standard_d4ads_v5" # 4vCPUs, 14GiB
    "staging"   = "standard_d4ads_v5" # 4vCPUs, 14GiB
    "prod"   = "standard_d4ads_v5" # 4vCPUs, 14GiB
  }
}
variable "ssh_pub_key_secret_name" {
  type = map
  default = {
    "default"   = "aks-dev-ssh-pub"
    "dev"       = "aks-dev-ssh-pub"
    "staging"   = "aks-staging-ssh-pub"
    "prod"      = "aks-prod-ssh-pub"
  }
}
variable "aks_ingress_lb_ip" {
  type = map
  default = {
    "default"  = "10.1.127.200"
    "dev"    = "10.1.127.200"
    "staging"   = "10.2.127.200"
    "prod"   = "10.3.127.200"
  }
}
variable "end_date" {
  default = "2025-01-01T01:02:03Z"
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
  env_tags = merge(var.default_tags, tomap({
    "Environment" = local.environment
  }))

  env_vnet_cidr               = lookup(var.vnet_cidr, terraform.workspace)
  env_node_count              = lookup(var.node_count, terraform.workspace)
  env_node_size               = lookup(var.node_size, terraform.workspace)
  env_aks_node_pool_cidr      = lookup(var.aks_node_pool_cidr, terraform.workspace)
  env_aks_ingress_lb_ip       = lookup(var.aks_ingress_lb_ip, terraform.workspace)
  env_ssh_pub_key_secret_name = lookup(var.ssh_pub_key_secret_name, terraform.workspace)
  env_aks_max_pod_number      = lookup(var.aks_max_pod_number, terraform.workspace)
}
