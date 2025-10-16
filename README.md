# terraform-azurerm-cosmos-db-vcore (Mongo Cluster)

Terraform module to provision Azure Cosmos DB for MongoDB vCore (azurerm_mongo_cluster) with optional Private Endpoint + Private DNS.

## Features
- Create Mongo vCore cluster (default version: 5.0)
- Zone‑level High Availability (within the same region) via `enable_high_availability`
- Private networking (Private Endpoint + DNS zone `privatelink.mongo.cosmos.azure.com`) when `network_mode = "private"`

## Inputs

| name | description | default | options |
| --- | --- | --- | --- |
| `name` | Cluster name. | — | string |
| `resource_group_name` | Target resource group. | — | string |
| `location` | Azure region. | — | string (e.g., `eastus`, `westus2`) |
| `administrator_username` | Initial admin username. | — | string |
| `administrator_password` | Initial admin password. | — | string (sensitive) |
| `mongo_version` | MongoDB server version. | `"5.0"` | per provider support |
| `network_mode` | Connectivity mode. `private` disables public access and creates Private Endpoint + DNS. | `"public"` | `public`, `private` |
| `subnet_id` | Subnet for Private Endpoint. Required when `network_mode = "private"`. | `null` | Azure subnet resource ID |
| `tags` | Resource tags. | `{}` | map(string) |
| `cluster_tier` | Sizing and HA settings (see fields below). | see defaults | object |

cluster_tier fields

| field | description | default | options |
| --- | --- | --- | --- |
| `compute_tier` | Compute SKU. | `"M10"` | `M10`, `M20`, `M30`, ... |
| `storage_size_in_gb` | Storage per shard. | `32` | number |
| `shard_count` | Number of shards. | `1` | integer ≥ 1 |
| `enable_high_availability` | Zone‑level HA (within same region). | `true` | `true`, `false` |

## Examples

Private network mode
```hcl
module "cosmos_db_vcore" {
  source = "azure-terraform-module/cosmosdb-mongodb-vcore
Public/azure"
  version = "0.0.1"

  name                = "cosmosdb-mongo"
  resource_group_name = "rg-app"
  location            = "westus2"

  administrator_username = "adminuser"
  administrator_password = "P@ssw0rd123!"

  network_mode = "private"
  subnet_id    = "/subscriptions/xxx/resourceGroups/rg-net/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe-subnet"

  cluster_tier = {
    compute_tier             = "M20"
    storage_size_in_gb       = 64
    shard_count              = 2
    enable_high_availability = true
  }

  tags = { env = "dev" }
}
```

Public network mode
```hcl
module "cosmos_db_vcore" {
  source = "azure-terraform-module/cosmosdb-mongodb-vcore
Public/azure"
  version = "0.0.1"

  name                = "cosmosdb-mongo-public"
  resource_group_name = "rg-app"
  location            = "westus2"

  administrator_username = "adminuser"
  administrator_password = "P@ssw0rd123!"

  network_mode = "public"

  cluster_tier = {
    compute_tier             = "M10"
    storage_size_in_gb       = 32
    shard_count              = 1
    enable_high_availability = false
  }

  tags = { env = "dev" }
}
```

## Notes
- With `network_mode = "private"`, the module creates a Private DNS Zone `privatelink.mongo.cosmos.azure.com` and a Private Endpoint (subresource `mongoCluster`), and disables public network access.
