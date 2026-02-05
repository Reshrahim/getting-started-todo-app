variable "app_name" {
  description = "Application name"
  default     = "todo"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  default     = "dev"
}

variable "location" {
  description = "Azure region"
  default     = "eastus"
}

variable "mysql_password" {
  description = "MySQL admin password"
  sensitive   = true
}
