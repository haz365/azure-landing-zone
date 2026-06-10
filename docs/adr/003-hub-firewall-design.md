# ADR-003: Hub Firewall Design

## Context
The hub VNet is the shared services network that all spoke VNets peer with. In production it should contain a centralised firewall for east-west traffic inspection and a VPN or ExpressRoute gateway for on-premises connectivity.

## Decision
For this build, NSGs and a User Defined Route on the hub shared subnet are used instead of Azure Firewall. Azure Firewall Basic costs approximately £1 per hour and takes 10-15 minutes to provision, making it impractical for a portfolio build. The firewall topology is fully documented here and would be the first addition in a production deployment. The GatewaySubnet is provisioned and reserved for a future VPN or ExpressRoute gateway.

## Consequence
Traffic between hub and spoke is controlled by NSGs rather than deep packet inspection. In production Azure Firewall Premium would sit in the hub, all spoke UDRs would point to the firewall private IP as the next hop, and all egress traffic would be inspected before leaving the VNet. This is equivalent to running a transit VPC with a firewall appliance on AWS.
