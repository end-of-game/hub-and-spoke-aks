# Application and Service Principal
resource "random_string" "password" {
  length = 32
}
resource "azuread_application" "aks" {
  display_name               = local.stack_name
  homepage                   = "https://${local.stack_name}"
  available_to_other_tenants = false
}
resource "azuread_service_principal" "aks" {
  application_id               = azuread_application.aks.application_id
  app_role_assignment_required = false
}
resource "azuread_service_principal_password" "aks" {
  service_principal_id = azuread_service_principal.aks.id
  value                = random_string.password.result
  end_date             = var.end_date

  # wait 30s for server replication before attempting role assignment creation
  provisioner "local-exec" {
    command = "sleep 30"
  }
}
resource "azurerm_role_assignment" "aks" {
  role_definition_name = "Network Contributor"
  scope                = azurerm_subnet.aks.id
  principal_id         = azuread_service_principal.aks.id
}

# Assign AcrPull role to service principal
resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_resource_group.aks.id
  role_definition_name             = "AcrPull"
  principal_id                     = azuread_service_principal.aks.id
  skip_service_principal_aad_check = true
}

# Get SSH key from Azure Key Vault
data "azurerm_key_vault_secret" "pub" {
  name         = local.env_ssh_pub_key_secret_name
  key_vault_id = data.azurerm_key_vault.vault.id
}

# Cluster AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.stack_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = local.stack_name
  kubernetes_version  = "1.19.6"

  linux_profile {
    admin_username = var.node_admin_username

    ssh_key {
      key_data = data.azurerm_key_vault_secret.pub.value
    }
  }

  default_node_pool {
    name                 = format("aks${local.environment}pool")
    node_count           = local.env_node_count
    max_pods             = var.env_aks_max_pod_number
    type                 = "VirtualMachineScaleSets"
    vm_size              = local.env_node_size
    os_disk_type         = "Ephemeral"
    vnet_subnet_id       = azurerm_subnet.aks.id
    orchestrator_version = "1.19.6"
    availability_zones   = ["1", "2"]
    tags                 = local.env_tags
  }

  service_principal {
    client_id     = azuread_service_principal.aks.application_id
    client_secret = azuread_service_principal_password.aks.value
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "azure"
  }

  tags = local.env_tags
}
