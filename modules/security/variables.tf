variable "location" {
  description = "Azure region"
  type        = string
}

variable "spoke_resource_group" {
  description = "Resource group for spoke resources"
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  sensitive   = true
}

variable "pe_subnet_id" {
  description = "Private endpoints subnet ID"
  type        = string
}

variable "keyvault_dns_zone_id" {
  description = "Key Vault private DNS zone ID"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
