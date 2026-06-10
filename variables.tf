variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "hasan-ali"
    costCenter  = "platform"
  }
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  default     = "27cbfddf-1489-4c47-a1b0-37fa3521a2ee"
}
