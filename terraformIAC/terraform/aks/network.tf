resource "azurerm_virtual_network" "aks" {
  name                = local.stack_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = [local.env_vnet_cidr]

  tags = local.env_tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = [local.env_aks_node_pool_cidr]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}
