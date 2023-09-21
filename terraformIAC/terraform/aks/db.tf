//cosmos db
resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "cosmosdb-${local.environment}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level       = "Session"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }
  geo_location {
    location          = azurerm_resource_group.aks.location
    failover_priority = 0
  }
  enable_automatic_failover = false
  enable_multiple_write_locations = false
}