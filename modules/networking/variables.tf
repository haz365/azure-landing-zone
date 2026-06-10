variable "location" {
  description = "Azure region"
  type        = string
}

variable "hub_resource_group" {
  description = "Resource group for hub resources"
  type        = string
}

variable "spoke_resource_group" {
  description = "Resource group for spoke resources"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
