locals {
  default_tags = merge({
    application = var.application_name
  }, var.tags)
}

resource "azurerm_resource_group" "amr_rg" {
  name     = "rg-${var.application_name}" # Dynamically build the resource group name
  location = var.resource_group_location

  tags = local.default_tags
}

module "keyvault" {
  source = "./modules/keyvault"

  count = var.use_managed_identities ? 0 : 1

  application_name        = var.application_name
  resource_group_name     = azurerm_resource_group.amr_rg.name
  resource_group_location = var.resource_group_location
  tags                    = local.default_tags
}

module "redis" {
  source = "./modules/redis"

  providers = {
    azapi = azapi
    azurerm = azurerm
  }

  resource_group_id     = azurerm_resource_group.amr_rg.id
  location              = var.resource_group_location
  tags                  = local.default_tags
  application_name      = var.application_name
  use_managed_identity  = var.use_managed_identities
  key_vault_id          = var.use_managed_identities ? null : module.keyvault[0].key_vault_id
}
