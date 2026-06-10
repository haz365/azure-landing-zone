# ADR-002: Private by Default

## Context
Workloads running in the spoke VNet must not be reachable from the public internet. Relying on engineers to manually configure private access on every resource is error-prone and does not scale.

## Decision
Implemented private-by-default at two levels. First, an Azure Policy assignment at Management Group scope actively denies any resource that attempts to attach a public IP — this is enforced infrastructure governance, not a guideline. Second, the Key Vault has no public network access and is reachable only via a Private Endpoint in the spoke VNet, with DNS resolution handled by a Private DNS Zone linked to both VNets. NSGs on all spoke subnets deny inbound traffic from the internet.

## Consequence
No resource in the Landing-Zones scope can accidentally expose a public IP. In production, ingress would be fronted by an Application Gateway or Azure Front Door with WAF in the hub VNet, providing a single controlled entry point. This maps to the AWS pattern of private subnets with no internet gateway, traffic entering only via ALB.
