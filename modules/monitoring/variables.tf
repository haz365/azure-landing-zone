variable "location" {
  description = "Azure region"
  type        = string
}

variable "monitoring_resource_group" {
  description = "Resource group for monitoring resources"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for diagnostic settings"
  type        = string
}

variable "spoke_vnet_id" {
  description = "Spoke VNet ID for diagnostic settings"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
