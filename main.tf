terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatee3701db4"
    container_name       = "tfstate"
    key                  = "alz.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "27cbfddf-1489-4c47-a1b0-37fa3521a2ee"
}

# ── Resource Groups ──────────────────────────────────────────────
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-spoke"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "monitoring" {
  name     = "rg-monitoring"
  location = var.location
  tags     = var.tags
}

# ── Management Groups ─────────────────────────────────────────────
module "management_groups" {
  source          = "./modules/management-groups"
  subscription_id = var.subscription_id
}

# ── Networking ────────────────────────────────────────────────────
module "networking" {
  source               = "./modules/networking"
  location             = var.location
  hub_resource_group   = azurerm_resource_group.hub.name
  spoke_resource_group = azurerm_resource_group.spoke.name
  tags                 = var.tags

  depends_on = [
    azurerm_resource_group.hub,
    azurerm_resource_group.spoke
  ]
}

# ── Monitoring ────────────────────────────────────────────────────
module "monitoring" {
  source                    = "./modules/monitoring"
  location                  = var.location
  monitoring_resource_group = azurerm_resource_group.monitoring.name
  hub_vnet_id               = module.networking.hub_vnet_id
  spoke_vnet_id             = module.networking.spoke_vnet_id
  tags                      = var.tags

  depends_on = [
    azurerm_resource_group.monitoring,
    module.networking
  ]
}
