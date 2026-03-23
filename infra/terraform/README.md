# AiClod Terraform Infrastructure

This directory contains provider-specific Terraform entry points for the one-click bootstrap flow.

## Providers

- `aws/` for Amazon EKS
- `gcp/` for Google Kubernetes Engine
- `azure/` for Azure Kubernetes Service

## Usage

1. Copy the provider's `terraform.tfvars.example` to `terraform.tfvars`.
2. Fill in the required project/account details.
3. Run the one-click bootstrap command for that provider.
