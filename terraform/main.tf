resource "azurerm_resource_group" "amr_rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azapi_resource" "amr_cluster" {
  type = "Microsoft.Cache/redisEnterprise@2024-10-01"
  name = var.cluster_name
  parent_id = azurerm_resource_group.amr_rg.id

  location = azurerm_resource_group.amr_rg.location

  tags = {
    mytag = "tag value"
  }

  body = {
    properties = {
      minimumTlsVersion = "1.2"
    }
    sku = {
      name = var.sku
    }
  }
}

resource "azapi_resource" "amr_db" {
  type = "Microsoft.Cache/redisEnterprise/databases@2024-10-01"
  name = "default"
  parent_id = azapi_resource.amr_cluster.id

  body = {
    properties = {
      clusteringPolicy = "EnterpriseCluster"
      evictionPolicy = "NoEviction"
      modules = [
        {
          name = "RediSearch"
        },
        {
          name = "RedisJson"
        }
      ]
      persistence = {
        aofEnabled = true
        aofFrequency = "1s"
      }
    }
  }
}

data "azapi_resource_action" "listKeys" {
  type = "Microsoft.Cache/redisEnterprise/databases@2024-10-01"
  resource_id = azapi_resource.amr_db.id
  action = "listKeys"
  response_export_values = ["*"]
}
