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

variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "sku" {
  type = string
  default = "Balanced_B0"
  description = "The Azure Managed Redis SKU"
}

variable "use_managed_identities" {
  type = bool
  default = true
  description = "Use Managed Identities?"
}

variable "tags" {
  description = "Optional. The tags to be assigned to the created resources."
  type        = map(string)
  default     = {}
}