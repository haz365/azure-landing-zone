# ── Management Group Hierarchy ────────────────────────────────────
# AWS equivalent: Organizations → Root → OUs
#
# Root (tenant)
# └── Platform-Org        (top-level MG)
#     ├── Platform         (shared services)
#     ├── Landing-Zones    (workload subscriptions) ← your sub goes here
#     └── Sandbox          (dev/test)

data "azurerm_client_config" "current" {}

resource "azurerm_management_group" "org" {
  display_name = "Platform-Org"
}

resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  parent_management_group_id = azurerm_management_group.org.id
}

resource "azurerm_management_group" "landing_zones" {
  display_name               = "Landing-Zones"
  parent_management_group_id = azurerm_management_group.org.id
}

resource "azurerm_management_group" "sandbox" {
  display_name               = "Sandbox"
  parent_management_group_id = azurerm_management_group.org.id
}

# ── Move subscription under Landing-Zones ────────────────────────
# AWS equivalent: moving an account into an OU
resource "azurerm_management_group_subscription_association" "landing_zones" {
  management_group_id = azurerm_management_group.landing_zones.id
  subscription_id     = "/subscriptions/${var.subscription_id}"
}

# ── Azure Policy Assignments ──────────────────────────────────────
# AWS equivalent: Service Control Policies (SCPs)

# Policy 1 - Deny public IPs on network interfaces
# Most important policy - enforces private-by-default
resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip"
  display_name         = "Deny public IP addresses"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"

  enforce = true
}

# Policy 2 - Require costCenter tag on resource groups
resource "azurerm_management_group_policy_assignment" "require_tags" {
  name                 = "require-cost-center-tag"
  display_name         = "Require costCenter tag on resource groups"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"

  enforce = true

  parameters = jsonencode({
    tagName = {
      value = "costCenter"
    }
  })
}

# Policy 3 - Restrict allowed regions
resource "azurerm_management_group_policy_assignment" "allowed_regions" {
  name                 = "allowed-regions"
  display_name         = "Restrict resources to UK regions only"
  management_group_id  = azurerm_management_group.landing_zones.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  enforce = true

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["uksouth", "ukwest"]
    }
  })
}
