# =============================================================================
# Development Environment Configuration
# =============================================================================

app_name       = "todoapp"
environment    = "dev"
location       = "eastus"
location_short = "eus"
owner          = "platform-team"
cost_center    = "todoapp-retail"

# MySQL Configuration (cost-optimized for dev)
mysql_sku_name   = "B_Standard_B1ms"
mysql_storage_gb = 20
mysql_iops       = 360

# Redis Configuration (cost-optimized for dev)
redis_capacity = 0
redis_family   = "C"
redis_sku_name = "Basic"

# Container Registry (Basic for dev)
acr_sku = "Basic"
