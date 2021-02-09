# Create container registry
resource "azurerm_container_registry" "acr" {
  name                     = "hasacr${local.environment}"
  resource_group_name      = azurerm_resource_group.aks.name
  location                 = var.location
  sku                      = "Standard"

  tags = local.env_tags
}