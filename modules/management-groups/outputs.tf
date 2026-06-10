output "landing_zones_mg_id" {
  description = "Landing Zones management group ID"
  value       = azurerm_management_group.landing_zones.id
}

output "platform_mg_id" {
  description = "Platform management group ID"
  value       = azurerm_management_group.platform.id
}

output "sandbox_mg_id" {
  description = "Sandbox management group ID"
  value       = azurerm_management_group.sandbox.id
}
