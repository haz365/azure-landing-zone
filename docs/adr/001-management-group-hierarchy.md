# ADR-001: Management Group Hierarchy

## Context
The landing zone needs a governance structure that separates platform shared services from workload subscriptions and sandbox environments. Policies applied at a higher scope must automatically inherit down to child scopes without manual re-application.

## Decision
Implemented a three-tier Management Group hierarchy under a top-level Platform-Org group: Platform for shared services, Landing-Zones for workload subscriptions and Sandbox for dev and test. The Azure subscription sits under Landing-Zones. Azure Policy assignments are made at the Landing-Zones scope so they apply to all current and future workload subscriptions automatically.

## Consequence
Policy inheritance means any new subscription placed under Landing-Zones automatically receives all guardrails with no additional configuration. In production each environment (dev, staging, prod) would have its own subscription under Landing-Zones. This maps directly to AWS Organizations where SCPs applied to an OU are inherited by all accounts within it.
