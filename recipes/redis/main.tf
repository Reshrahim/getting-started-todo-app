# Radius Recipe: Redis Cache for Kubernetes
# This module deploys a Redis instance on Kubernetes

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
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
  port      = 6379
}

# Redis Deployment
resource "kubernetes_deployment" "redis" {
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
          name  = "redis"
          image = "redis:7-alpine"

          port {
            container_port = local.port
          }

          resources {
            limits = {
              memory = "128Mi"
              cpu    = "250m"
            }
            requests = {
              memory = "64Mi"
              cpu    = "100m"
            }
          }
        }
      }
    }
  }
}

# Redis Service
resource "kubernetes_service" "redis" {
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
      host     = "${kubernetes_service.redis.metadata[0].name}.${local.namespace}.svc.cluster.local"
      port     = local.port
      password = ""
    }
  }
}
