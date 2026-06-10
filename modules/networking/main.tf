# ── Hub and Spoke Networking ──────────────────────────────────────
# AWS equivalent:
# Hub VNet    = Transit VPC / shared services VPC
# Spoke VNet  = Workload VPC
# VNet Peering = VPC Peering (but must be done both directions)
# NSG          = Security Group (but attached to subnet not instance)
# UDR          = Route Table
# Private DNS Zone = Route53 Private Hosted Zone

# ── Hub VNet ──────────────────────────────────────────────────────
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  resource_group_name = var.hub_resource_group
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

# Hub subnets
resource "azurerm_subnet" "hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.hub_resource_group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub_shared" {
  name                 = "snet-shared"
  resource_group_name  = var.hub_resource_group
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ── Spoke VNet ────────────────────────────────────────────────────
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke"
  resource_group_name = var.spoke_resource_group
  location            = var.location
  address_space       = ["10.1.0.0/16"]
  tags                = var.tags
}

# Spoke subnets
resource "azurerm_subnet" "spoke_workload" {
  name                 = "snet-workload"
  resource_group_name  = var.spoke_resource_group
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "spoke_private_endpoints" {
  name                 = "snet-pe"
  resource_group_name  = var.spoke_resource_group
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}

# ── VNet Peering ──────────────────────────────────────────────────
# AWS equivalent: VPC Peering
# Unlike AWS, Azure peering must be created in BOTH directions

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = var.hub_resource_group
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = var.spoke_resource_group
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  use_remote_gateways       = false
}

# ── NSG on workload subnet ────────────────────────────────────────
# AWS equivalent: Security Group (but applied to subnet not instance)

resource "azurerm_network_security_group" "workload" {
  name                = "nsg-workload"
  resource_group_name = var.spoke_resource_group
  location            = var.location
  tags                = var.tags

  # Deny all inbound from internet
  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow inbound from hub VNet
  security_rule {
    name                       = "AllowHubInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.0.0/16"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "workload" {
  subnet_id                 = azurerm_subnet.spoke_workload.id
  network_security_group_id = azurerm_network_security_group.workload.id
}

# ── NSG on private endpoints subnet ──────────────────────────────
resource "azurerm_network_security_group" "private_endpoints" {
  name                = "nsg-pe"
  resource_group_name = var.spoke_resource_group
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.spoke_private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints.id
}

# ── User Defined Route (UDR) on hub ──────────────────────────────
# AWS equivalent: Route Table
# Forces traffic through hub for inspection in production
resource "azurerm_route_table" "hub" {
  name                = "rt-hub"
  resource_group_name = var.hub_resource_group
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "hub_shared" {
  subnet_id      = azurerm_subnet.hub_shared.id
  route_table_id = azurerm_route_table.hub.id
}

# ── Private DNS Zone ──────────────────────────────────────────────
# AWS equivalent: Route53 Private Hosted Zone
# Used for Key Vault private endpoint DNS resolution

resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.hub_resource_group
  tags                = var.tags
}

# Link DNS zone to spoke VNet so workloads can resolve Key Vault
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_spoke" {
  name                  = "kv-dns-link-spoke"
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}

# Link DNS zone to hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_hub" {
  name                  = "kv-dns-link-hub"
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = var.tags
}
