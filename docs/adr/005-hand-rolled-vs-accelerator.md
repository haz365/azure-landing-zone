# ADR-005: Hand-rolled vs ALZ Accelerator

## Context
Microsoft provides the Azure Landing Zones IaC Accelerator with Azure Verified Modules as the recommended production path for deploying landing zones. An alternative is to build the primitives by hand using the azurerm Terraform provider directly.

## Decision
Built hand-rolled Terraform modules rather than using the ALZ Accelerator. The purpose of this build is to demonstrate understanding of the underlying Azure primitives — management groups, policy assignments, VNet peering, private endpoints, managed identities. Using the accelerator would abstract these away and make it harder to defend in an interview.

## Consequence
The hand-rolled approach provides deep understanding of every resource and its configuration. In a production engagement the recommendation would be to use the ALZ Accelerator with Azure Verified Modules — it encodes years of Microsoft best practice, handles edge cases, and is actively maintained. The classic caf-enterprise-scale Terraform module is being deprecated in 2026; AVM is the current production path.
