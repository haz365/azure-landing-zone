output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "workload_identity_id" {
  description = "Workload managed identity ID"
  value       = azurerm_user_assigned_identity.workload.id
}

output "workload_identity_client_id" {
  description = "Workload managed identity client ID"
  value       = azurerm_user_assigned_identity.workload.client_id
  sensitive   = true
}

output "workload_identity_principal_id" {
  description = "Workload managed identity principal ID"
  value       = azurerm_user_assigned_identity.workload.principal_id
}
