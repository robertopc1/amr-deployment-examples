variable "subscription_id" {
  type = string
  description = "The id of the Azure subscription"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resource group created for the AMR cluster"
}

variable "resource_group_location" {
  type = string
  default = "UK South"
  description = "The Azure region of the resource group"
}

variable "cluster_name" {
  type = string
  description = "The name of the AMR cluster"
}

variable "sku" {
  type = string
  default = "Balanced_B0"
  description = "The Azure Managed Redis SKU"
}
