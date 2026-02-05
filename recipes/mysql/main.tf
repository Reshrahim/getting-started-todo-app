# Radius Recipe: MySQL Database for Kubernetes
# This module deploys a MySQL instance on Kubernetes

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# Radius context variable - provided by Radius during deployment
variable "context" {
  description = "Radius-provided context for the recipe"
  type = object({
    resource = object({
      name = string
      id   = string
      type = string
    })
    application = optional(object({
      name = string
      id   = string
    }))
    environment = object({
      name = string
      id   = string
    })
    runtime = object({
      kubernetes = object({
        namespace            = string
        environmentNamespace = string
      })
    })
  })
}

locals {
  name      = var.context.resource.name
  namespace = var.context.runtime.kubernetes.namespace
  port      = 3306
  database  = "todos"
  username  = "radius"
}

# Generate random password
resource "random_password" "mysql" {
  length  = 16
  special = false
}

# MySQL Secret
resource "kubernetes_secret" "mysql" {
  metadata {
    name      = "${local.name}-secret"
    namespace = local.namespace
  }

  data = {
    MYSQL_ROOT_PASSWORD = random_password.mysql.result
    MYSQL_PASSWORD      = random_password.mysql.result
  }
}

# MySQL Deployment
resource "kubernetes_deployment" "mysql" {
  metadata {
    name      = local.name
    namespace = local.namespace
    labels = {
      app                           = local.name
      "radapp.io/resource"          = var.context.resource.id
      "radapp.io/environment"       = var.context.environment.id
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"

          port {
            container_port = local.port
          }

          env {
            name  = "MYSQL_DATABASE"
            value = local.database
          }

          env {
            name  = "MYSQL_USER"
            value = local.username
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql.metadata[0].name
                key  = "MYSQL_PASSWORD"
              }
            }
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql.metadata[0].name
                key  = "MYSQL_ROOT_PASSWORD"
              }
            }
          }

          resources {
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }
        }
      }
    }
  }
}

# MySQL Service
resource "kubernetes_service" "mysql" {
  metadata {
    name      = local.name
    namespace = local.namespace
    labels = {
      app = local.name
    }
  }

  spec {
    selector = {
      app = local.name
    }

    port {
      port        = local.port
      target_port = local.port
    }

    type = "ClusterIP"
  }
}

# Outputs required by Radius
output "result" {
  description = "Recipe output values"
  value = {
    values = {
      host     = "${kubernetes_service.mysql.metadata[0].name}.${local.namespace}.svc.cluster.local"
      port     = local.port
      database = local.database
      username = local.username
      password = random_password.mysql.result
    }
  }
  sensitive = true
}
