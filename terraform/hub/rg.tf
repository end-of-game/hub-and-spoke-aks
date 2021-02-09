resource "azurerm_resource_group" "hub" {
  name     = local.stack_name
  location = var.location

  tags = merge(var.default_tags)
}