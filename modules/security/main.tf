data "azurerm_client_config" "current" {}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

resource "azurerm_key_vault" "main" {
  name                          = "kv-platform-${substr(var.subscription_id, 0, 8)}"
  resource_group_name           = var.spoke_resource_group
  location                      = var.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-workload"
  resource_group_name = var.spoke_resource_group
  location            = var.location
  tags                = var.tags
}

resource "azurerm_key_vault_access_policy" "workload" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.workload.principal_id

  secret_permissions = [
    "Get", "List"
  ]
}

resource "azurerm_private_endpoint" "keyvault" {
  name                = "pe-keyvault"
  resource_group_name = var.spoke_resource_group
  location            = var.location
  subnet_id           = var.pe_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "kv-conn"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "kv-dns-group"
    private_dns_zone_ids = [var.keyvault_dns_zone_id]
  }
}
