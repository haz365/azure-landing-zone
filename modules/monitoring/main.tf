# ── Monitoring and Security ───────────────────────────────────────
# AWS equivalent:
# Log Analytics Workspace = CloudWatch Logs (central log aggregation)
# Defender for Cloud      = Security Hub + GuardDuty combined
# Diagnostic Settings     = CloudTrail + CloudWatch metrics

# ── Log Analytics Workspace ───────────────────────────────────────
# AWS equivalent: CloudWatch Log Group / centralized logging account
resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-platform"
  resource_group_name = var.monitoring_resource_group
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# ── Microsoft Defender for Cloud ──────────────────────────────────
# AWS equivalent: AWS Security Hub + GuardDuty
resource "azurerm_security_center_subscription_pricing" "defender_servers" {
  tier          = "Free"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Free"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_keyvault" {
  tier          = "Free"
  resource_type = "KeyVaults"
}

# ── Diagnostic settings for Hub VNet ─────────────────────────────
# AWS equivalent: VPC Flow Logs → CloudWatch
resource "azurerm_monitor_diagnostic_setting" "hub_vnet" {
  name                       = "diag-hub-vnet"
  target_resource_id         = var.hub_vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ── Diagnostic settings for Spoke VNet ───────────────────────────
resource "azurerm_monitor_diagnostic_setting" "spoke_vnet" {
  name                       = "diag-spoke-vnet"
  target_resource_id         = var.spoke_vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# ── Azure Monitor Action Group ────────────────────────────────────
# AWS equivalent: SNS Topic for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-platform-alerts"
  resource_group_name = var.monitoring_resource_group
  short_name          = "platform"
  tags                = var.tags
}
