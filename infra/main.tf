# Todo Application Infrastructure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-${var.environment}-rg"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# MySQL Database
resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.app_name}-mysql"
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  administrator_login    = "adminuser"
  administrator_password = var.mysql_password
  sku_name               = "B_Standard_B1ms"
  version                = "8.0.21"
}

resource "azurerm_mysql_flexible_database" "todos" {
  name                = "todos"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

# Redis Cache
resource "azurerm_redis_cache" "main" {
  name                = "${var.app_name}-redis"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}
