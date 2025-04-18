terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
      version = "~>2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

data "azurerm_client_config" "current" {}

// Removed the empty provider block for `azapi` as it is no longer needed.

resource "azapi_resource" "amr_cluster" {
  schema_validation_enabled = false
  type = "Microsoft.Cache/redisEnterprise@2024-09-01-preview"
  name = substr("redis-${var.application_name}-${var.location}", 0, 60) // Ensure name is valid
  parent_id = var.resource_group_id

  location = var.location

  tags = var.tags

  body = {
    properties = {
      minimumTlsVersion = "1.2"
      highAvailability = var.ha_option ? "Enabled" : "Disabled"
    }
    sku = {
      name = var.sku_name
    }
  }

  identity {
    type = var.use_managed_identity ? "SystemAssigned" : "None"
  }
}

resource "azapi_resource" "amr_db" {
  type = "Microsoft.Cache/redisEnterprise/databases@2024-09-01-preview"
  name = "default"
  parent_id = azapi_resource.amr_cluster.id
  body = {
    properties = {
      accessKeysAuthentication = var.use_managed_identity ? "Disabled" : "Enabled"
      clientProtocol = "Encrypted"
      port = 10000
      clusteringPolicy = var.clustering_policy
      evictionPolicy = var.eviction_policy
      persistence = {
        aofEnabled = var.persistence_option == "AOF"
        aofFrequency = var.persistence_option == "AOF" ? var.aof_frequency : null
        rdbEnabled = var.persistence_option == "RDB"
        rdbFrequency = var.persistence_option == "RDB" ? var.rdb_frequency : null
      }
      modules = [for module in var.modules_enabled : {
        name = module
      }]
    }
  }
}

data "azapi_resource_action" "listKeys" {
  type = "Microsoft.Cache/redisEnterprise/databases@2024-09-01-preview"
  resource_id = azapi_resource.amr_db.id
  action = "listKeys"
  response_export_values = ["*"]
}

//TODO: Update to give correct permissions to add the primary key to the Key Vault
resource "azurerm_key_vault_secret" "redis_password" {
  count = var.use_managed_identity ? 0 : 1

  name         = "redisPassword"
  value        = data.azapi_resource_action.listKeys.output.primaryKey
  key_vault_id = var.key_vault_id

  tags = var.tags
}

