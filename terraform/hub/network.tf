resource "azurerm_network_ddos_protection_plan" "hub" {
  name                = local.stack_name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_virtual_network" "hub" {
  name                = local.stack_name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.vnet_cidr]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.hub.id
    enable = true
  }

  tags = var.default_tags
}

resource "azurerm_subnet" "waf" {
  name                 = "waf"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_waf_cidr]
}

# Not used
resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_management_cidr]
}

# Vnet peering for spokes
data "azurerm_virtual_network" "spoke" {
  for_each            = toset(var.vnet_spoke_to_peer)
  name                = each.key
  resource_group_name = each.key
}
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  for_each                  = toset(var.vnet_spoke_to_peer)
  name                      = "hub-to-${each.key}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = data.azurerm_virtual_network.spoke[each.key].id
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  for_each                  = toset(var.vnet_spoke_to_peer)
  name                      = "${each.key}-to-hub"
  resource_group_name       = each.key
  virtual_network_name      = data.azurerm_virtual_network.spoke[each.key].name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}
