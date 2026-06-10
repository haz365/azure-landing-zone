output "hub_vnet_id" {
  description = "Hub VNet ID"
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  description = "Spoke VNet ID"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_workload_subnet_id" {
  description = "Spoke workload subnet ID"
  value       = azurerm_subnet.spoke_workload.id
}

output "spoke_pe_subnet_id" {
  description = "Spoke private endpoints subnet ID"
  value       = azurerm_subnet.spoke_private_endpoints.id
}

output "keyvault_dns_zone_id" {
  description = "Key Vault private DNS zone ID"
  value       = azurerm_private_dns_zone.keyvault.id
}

output "keyvault_dns_zone_name" {
  description = "Key Vault private DNS zone name"
  value       = azurerm_private_dns_zone.keyvault.name
}
