data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "amr_kv" {
  name                        = "kv-${var.application_name}-${var.resource_group_location}"
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name                    = "standard"
  enabled_for_template_deployment = true

  tags = var.tags
}
