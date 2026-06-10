# Azure Platform Landing Zone

A production-grade Azure platform landing zone built with Terraform, delivered through Azure DevOps Pipelines using Workload Identity Federation. No stored credentials anywhere in the pipeline or codebase.

**Stack:** Terraform · Azure DevOps · Hub-Spoke Networking · Azure Policy · Key Vault · Managed Identity

---

## What's Deployed

| Component | Azure Service | AWS Equivalent |
|---|---|---|
| Management Group hierarchy | Management Groups | AWS Organizations / OUs |
| Governance guardrails | Azure Policy | Service Control Policies (SCPs) |
| Remote state | Azure Storage + blob container | S3 + DynamoDB lock |
| Private network foundation | Hub VNet + Spoke VNet | Transit VPC + Workload VPC |
| Network segmentation | NSG + UDR | Security Groups + Route Tables |
| Private service access | Private Endpoints + Private DNS | PrivateLink + Route53 PHZ |
| Secret management | Azure Key Vault | AWS Secrets Manager |
| Workload identity | User-assigned Managed Identity | IAM Role / IRSA |
| Central logging | Log Analytics Workspace | CloudWatch Logs |
| Security posture | Microsoft Defender for Cloud | AWS Security Hub + GuardDuty |
| CI/CD | Azure DevOps Pipelines | GitHub Actions |
| Credential-free auth | Workload Identity Federation | GitHub Actions OIDC |

---

## Architecture

Tenant Root Group
└── Platform-Org (Management Group)
├── Platform
├── Landing-Zones ← subscription lives here
│   ├── Azure Policy: Deny public IPs
│   ├── Azure Policy: Require costCenter tag
│   └── Azure Policy: Restrict to UK regions
└── Sandbox
VPC: 10.0.0.0/8
├── Hub VNet (10.0.0.0/16)          [shared services]
│   ├── GatewaySubnet (10.0.1.0/24) [VPN/ExpressRoute in prod]
│   ├── snet-shared (10.0.2.0/24)   [shared services]
│   └── Private DNS Zone            [privatelink.vaultcore.azure.net]
│
└── Spoke VNet (10.1.0.0/16)        [workloads]
├── snet-workload (10.1.1.0/24) [application workloads]
│   └── NSG: deny internet inbound, allow hub
└── snet-pe (10.1.2.0/24)       [private endpoints]
└── Key Vault Private Endpoint

---

## Security Design

**Private by default** — enforced at policy level, not just configuration. The Azure Policy assignment at Management Group scope actively denies any resource that tries to attach a public IP. No engineer can accidentally expose a resource to the internet.

**Zero stored credentials** — the Azure DevOps pipeline authenticates via Workload Identity Federation. Azure DevOps presents a short-lived OIDC token to Azure AD, which exchanges it for an access token scoped to this subscription. No client secret, no certificate, nothing to rotate or leak. This is the same principle as GitHub Actions OIDC on AWS.

**Key Vault private only** — Key Vault is accessible only via Private Endpoint inside the spoke VNet. DNS resolution for `kv-platform-27cbfddf.vault.azure.net` resolves to a private IP via the Private DNS Zone linked to both VNets.

**Managed Identity over credentials** — workloads authenticate to Key Vault using a user-assigned Managed Identity. The identity has only `Get` and `List` permissions on secrets — no write, no delete.

---

## CI/CD Pipeline

Push to feature branch
└── PR raised against main
└── Plan stage runs
├── terraform init (WIF auth to storage account)
├── terraform fmt -check
├── terraform validate
└── terraform plan (output shown in PR)
Merge to main
└── Apply stage runs
├── terraform init
└── terraform apply -auto-approve

**How WIF authentication works:**
1. Azure DevOps requests a token from Azure AD using the service connection
2. Azure AD validates the issuer and subject match the federated credential
3. Azure AD returns a short-lived access token
4. Terraform uses the token to authenticate to Azure
5. No secret is stored, generated, or persisted anywhere

---

## Repository Structure

azure-landing-zone/
main.tf                         Root module — wires everything together
variables.tf                    Input variables
terraform.tfvars.example        Variable template — no real values
azure-pipelines.yml             Azure DevOps pipeline
modules/
management-groups/            MG hierarchy + Azure Policy assignments
networking/                   Hub VNet, spoke VNet, peering, NSGs, DNS
monitoring/                   Log Analytics, Defender for Cloud, diagnostics
security/                     Key Vault, Private Endpoint, Managed Identity
docs/
adr/                          Architecture Decision Records

---

## Local Development

```bash
# Prerequisites
brew install azure-cli terraform

# Login
az login
az account set --subscription "27cbfddf-1489-4c47-a1b0-37fa3521a2ee"

# Init and plan
terraform init
terraform plan -var="subscription_id=<your-subscription-id>"

# Apply
terraform apply -var="subscription_id=<your-subscription-id>"

# Destroy when done
terraform destroy -var="subscription_id=<your-subscription-id>"
```

---

## ADRs

- [ADR-001: Management Group Hierarchy](docs/adr/001-management-group-hierarchy.md)
- [ADR-002: Private by Default](docs/adr/002-private-by-default.md)
- [ADR-003: Hub Firewall Design](docs/adr/003-hub-firewall-design.md)
- [ADR-004: Terraform over Bicep](docs/adr/004-terraform-over-bicep.md)
- [ADR-005: Hand-rolled vs ALZ Accelerator](docs/adr/005-hand-rolled-vs-accelerator.md)
- [ADR-006: Workload Identity Federation over Stored Credentials](docs/adr/006-wif-over-stored-credentials.md)

