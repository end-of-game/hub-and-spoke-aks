resource "azurerm_resource_group" "aks" {
  name     = local.stack_name
  location = var.location

  tags = local.env_tags
}