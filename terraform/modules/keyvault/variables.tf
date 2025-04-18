variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Key Vault will be deployed"
  type        = string
}

variable "resource_group_location" {
  description = "The location of the resource group"
  type        = string
}

variable "tags" {
  description = "Optional. The tags to be assigned to the created resources."
  type        = map(string)
  default     = {}
}