# Terraform Infrastructure

## Overview

This directory contains Terraform configurations for provisioning the Todo application infrastructure on Azure following best practices.

## Resources Provisioned

- **Azure MySQL Flexible Server** - Primary database for todo items
- **Azure Cache for Redis** - Caching layer for improved performance
- **Azure Key Vault** - Secure secrets management
- **Azure Container Registry** - Container image storage
- **Azure Log Analytics** - Centralized logging
- **Azure Application Insights** - Application performance monitoring

## Best Practices Implemented

### Security
- ✅ Key Vault for secrets management (no hardcoded credentials)
- ✅ RBAC-based access control for Key Vault
- ✅ TLS 1.2 minimum for Redis connections
- ✅ Soft delete and purge protection for Key Vault
- ✅ Network ACLs for production environments

### Reliability
- ✅ Zone redundancy for production MySQL
- ✅ High availability configuration for production
- ✅ Geo-redundant backups for production MySQL
- ✅ Auto-grow storage for MySQL

### Cost Optimization
- ✅ Environment-specific SKU sizing (dev vs prod)
- ✅ Burstable tier for development workloads
- ✅ Basic/Standard tiers for non-production

### Operations
- ✅ Consistent naming conventions
- ✅ Resource tagging for cost allocation
- ✅ Centralized logging with Log Analytics
- ✅ Application Insights for APM

## Usage

### Prerequisites

```bash
# Install Terraform
brew install terraform  # macOS
# or download from https://terraform.io

# Login to Azure
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### Initialize

```bash
cd infra
terraform init
```

### Plan (Development)

```bash
terraform plan \
  -var-file="environments/dev.tfvars" \
  -var="mysql_admin_password=YOUR_SECURE_PASSWORD"
```

### Apply (Development)

```bash
terraform apply \
  -var-file="environments/dev.tfvars" \
  -var="mysql_admin_password=YOUR_SECURE_PASSWORD"
```

### Plan (Production)

```bash
terraform plan \
  -var-file="environments/prod.tfvars" \
  -var="mysql_admin_password=YOUR_SECURE_PASSWORD"
```

### Destroy

```bash
terraform destroy \
  -var-file="environments/dev.tfvars" \
  -var="mysql_admin_password=YOUR_SECURE_PASSWORD"
```

## File Structure

```
infra/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output value definitions
├── environments/
│   ├── dev.tfvars      # Development environment values
│   └── prod.tfvars     # Production environment values
└── README.md           # This file
```

## Outputs

After applying, you can retrieve outputs:

```bash
# Get all outputs
terraform output

# Get specific output
terraform output mysql_server_fqdn
terraform output redis_cache_hostname

# Get sensitive outputs
terraform output -raw application_insights_connection_string
```

## Remote State (Production)

For team collaboration, configure remote state in `main.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "tfstate-rg"
  storage_account_name = "tfstatestorage"
  container_name       = "tfstate"
  key                  = "todo-app.tfstate"
}
```

## Cost Estimates

| Environment | Monthly Estimate |
|-------------|------------------|
| Development | ~$50-80 USD      |
| Production  | ~$300-500 USD    |

*Estimates based on East US region pricing as of 2026.*
