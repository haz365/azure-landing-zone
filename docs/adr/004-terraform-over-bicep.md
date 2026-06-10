# ADR-004: Terraform over Bicep

## Context
Azure landing zones can be deployed with either Terraform or Bicep. Microsoft's own ALZ Accelerator supports both. A choice must be made for this build.

## Decision
Terraform was chosen over Bicep for three reasons. First, existing expertise — the same Terraform patterns used for AWS infrastructure (state backends, modules, variable files) translate directly to the azurerm provider. Second, multi-cloud portability — Terraform modules can be reused across AWS, Azure and GCP; Bicep is Azure-only. Third, the team at Avanade uses Terraform and the job description explicitly lists it as the primary IaC tool.

## Consequence
Bicep has advantages for Azure-specific features — tighter ARM integration, first-class support for Azure Verified Modules, and no state file to manage. Microsoft's own ALZ Accelerator uses Azure Verified Modules with both Terraform and Bicep. In production the recommendation would be to evaluate the ALZ Accelerator as the foundation rather than hand-rolling primitives, as the caf-enterprise-scale module is being deprecated in 2026 in favour of AVM.
