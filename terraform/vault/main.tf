# Create a dedicated resource group
resource "azurerm_resource_group" "vault" {
  name     = local.stack_name
  location = var.location

  tags = merge(var.default_tags)
}

# Create common Key Vault
resource "azurerm_key_vault" "vault" {
  name                            = "vaultspokevituity" 
  location                        = var.location
  resource_group_name             = azurerm_resource_group.vault.name
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = false
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false

  sku_name = "standard"
}

# Authorize Terraform to use keys, secrets and certificates
resource "azurerm_key_vault_access_policy" "tf" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "get",
  ]

  key_permissions = [
    "get",
    "create",
    "delete",
    "list",
    "purge",
  ]

  secret_permissions = [
    "get",
    "set",
    "list",
    "delete",
  ]
}

# Authorize administrator to use keys, secrets and certificates
resource "azurerm_key_vault_access_policy" "admin" {
  for_each     = toset(var.azure_administrator_object_id)
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  certificate_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
    "recover",
    "backup",
    "restore",
    "managecontacts",
    "listissuers",
    "manageissuers",
    "getissuers",
    "setissuers",
    "purge",
  ]

  key_permissions = [
    "get",
    "list",
    "update",
    "create",
    "import",
    "delete",
    "recover",
    "backup",
    "restore",
    "purge",
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set",
  ]
}
