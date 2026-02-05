# Radius Recipe: Azure Database for MySQL
# Copied from local repository: infra/main.tf
# This recipe wraps the MySQL resource definitions from your existing terraform code.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Disable Azure CLI auth - Radius injects service principal credentials via ARM_* env vars
  use_cli = false
}

variable "context" {
  description = "Radius-provided context for the recipe"
  type        = any
}

locals {
  name           = var.context.resource.name
  tags           = try(var.context.resource.tags, {})
  resource_group = try(var.context.azure.resourceGroup.name, "radius-${var.context.environment.name}")
  location       = try(var.context.azure.location, "eastus")
  database_name  = var.context.resource.name
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "random_password" "admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Azure Database for MySQL Flexible Server
# Copied from local infra/main.tf - azurerm_mysql_flexible_server resource
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${local.name}-${random_string.suffix.result}"
  resource_group_name    = local.resource_group
  location               = local.location
  administrator_login    = "mysqladmin"
  administrator_password = random_password.admin_password.result
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"

  tags = merge(local.tags, {
    "radapp.io/resource"    = var.context.resource.id
    "radapp.io/environment" = var.context.environment.id
  })
}

# MySQL Database
# Copied from local infra/main.tf - azurerm_mysql_flexible_database resource
resource "azurerm_mysql_flexible_database" "main" {
  name                = local.database_name
  resource_group_name = local.resource_group
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Firewall rule to allow Azure services
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure" {
  name                = "AllowAzureServices"
  resource_group_name = local.resource_group
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

output "result" {
  description = "Recipe output values for Radius"
  sensitive   = true
  value = {
    values = {
      host     = azurerm_mysql_flexible_server.main.fqdn
      port     = 3306
      database = azurerm_mysql_flexible_database.main.name
      username = "mysqladmin"
    }
    secrets = {
      password         = random_password.admin_password.result
      connectionString = "mysql://mysqladmin:${random_password.admin_password.result}@${azurerm_mysql_flexible_server.main.fqdn}:3306/${azurerm_mysql_flexible_database.main.name}"
    }
    resources = [
      azurerm_mysql_flexible_server.main.id
    ]
  }
}
