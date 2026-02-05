# =============================================================================
# Production Environment Configuration
# =============================================================================

app_name       = "todoapp"
environment    = "prod"
location       = "eastus"
location_short = "eus"
owner          = "platform-team"
cost_center    = "todoapp-retail"

# MySQL Configuration (production-grade)
mysql_sku_name   = "GP_Standard_D2ds_v4"
mysql_storage_gb = 64
mysql_iops       = 500

# Redis Configuration (production-grade with HA)
redis_capacity = 1
redis_family   = "P"
redis_sku_name = "Premium"

# Container Registry (Premium for geo-replication and security)
acr_sku = "Premium"
