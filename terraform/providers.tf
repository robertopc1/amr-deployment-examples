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

provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
