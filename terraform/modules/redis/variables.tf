variable "location" {
  description = "Required. Azure location to which the resources are to be deployed"
  type        = string
}

variable "resource_group_id" {
  description = "The ID of the resource group where the Redis resources will be deployed"
  type        = string
}

variable "key_vault_id" {
  description = "Required. Key Vault Id"
  type        = string
}
variable "sku_name" {
  description = "Optional. The Azure Managed Redis SKU"
  type        = string
  default     = "MemoryOptimized_M10"
}

variable "clustering_policy" {
  description = "Optional. The Azure Managed Enterprise clustering policy"
  type        = string
  default     = "EnterpriseCluster"
}

variable "eviction_policy" {
  description = "Optional. The Azure Managed Redis eviction policy"
  type        = string
  default     = "NoEviction"
}

variable "persistence_option" {
  description = "Optional. Persist data stored in Azure Managed Redis"
  type        = string
  default     = "Disabled"
}

variable "aof_frequency" {
  description = "Optional. The frequency at which data is written to disk"
  type        = string
  default     = "1s"
}

variable "rdb_frequency" {
  description = "Optional. The frequency at which a snapshot of the database is created"
  type        = string
  default     = "6h"
}

variable "modules_enabled" {
  description = "Optional. The Azure Managed Redis module(s)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Optional. The tags to be assigned to the created resources"
  type        = map(string)
  default     = {}
}

variable "ha_option" {
  description = "Required. Enable High Availability"
  type        = bool
  default     = true
}

variable "application_name" {
  description = "Required. Application name"
  type        = string
}

variable "use_managed_identity" {
  description = "Optional. Use Managed Identity for authentication. If false, key-based authentication will be used"
  type        = bool
  default     = true
}