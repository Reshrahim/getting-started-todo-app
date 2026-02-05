output "mysql_host" {
  description = "MySQL server hostname"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "redis_host" {
  description = "Redis cache hostname"
  value       = azurerm_redis_cache.main.hostname
}
