# Declarative infrastructure for orders-api. Illustrative and provider-light on
# purpose. CI runs `terraform validate` only; the cluster is reconciled by
# GitOps, not by `terraform apply` from a pipeline.

terraform {
  required_version = ">= 1.6.0"
}

variable "image_tag" {
  type        = string
  description = "Container image tag deployed for orders-api."
}

variable "replicas" {
  type    = number
  default = 2
}

# A declarative description of the desired runtime. In a real project this would
# reference a kubernetes or cloud-run provider; kept abstract here so the file
# reads as intent, not vendor boilerplate.
locals {
  service = {
    name     = "orders-api"
    image    = "registry.example.com/orders-api:${var.image_tag}"
    replicas = var.replicas
    env = {
      ORDERS_DB_URL = "from-secret-manager" # never a literal secret in the repo
    }
  }
}

output "desired_state" {
  value = local.service
}
