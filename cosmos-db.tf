resource "azurerm_mongo_cluster" "cosmos_db" {
  # Basic settings
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_username = var.administrator_username
  administrator_password = var.administrator_password
  version                = var.mongo_version
 
  # Cluster tier settings
  compute_tier = var.cluster_tier.compute_tier
  storage_size_in_gb = var.cluster_tier.storage_size_in_gb
  shard_count = var.cluster_tier.shard_count
  high_availability_mode = var.cluster_tier.enable_high_availability ? "ZoneRedundantPreferred" : "Disabled"

  # Networking settings
  public_network_access = local.is_public_network ? "Enabled" : "Disabled"
  tags = var.tags
}

resource "azurerm_private_dns_zone" "private_dns_cosmos_db" {
  # Create if private network and private DNS zone is not provided
  count = ! local.is_public_network ? 1 : 0
  name                = "privatelink.mongocluster.cosmos.azure.com"
  resource_group_name = var.resource_group_name
  tags = var.tags
}

# vnet link
resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  count = ! local.is_public_network ? 1 : 0
  name = "privatelink.mongocluster.cosmos.azure.com"
  resource_group_name = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_cosmos_db[0].name
  virtual_network_id = var.subnet_id
}

# Create private endpoint - Private endpoint
resource "azurerm_private_endpoint" "cosmos_db_private_endpoint" {
  count = local.is_public_network ? 0 : 1
  name                = "${var.name}-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-private-connection"
    private_connection_resource_id = azurerm_mongo_cluster.cosmos_db.id
    is_manual_connection           = false
    subresource_names              = ["mongoCluster"]
  }

  dynamic "private_dns_zone_group" {
    for_each = !local.is_public_network ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_cosmos_db[0].id]
    }
  }

  tags = var.tags
}
