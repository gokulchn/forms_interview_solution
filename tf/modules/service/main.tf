terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.0.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

variable "service_name" {}
variable "image"        {}
variable "environment"  {}
variable "network"      {}
variable "frontend_port" {
  type    = number
  default = null
}

resource "vault_generic_secret" "secret" {
  provider  = vault
  path      = "secret/${var.environment}/${var.service_name}"
  data_json = jsonencode({
    db_user     = var.service_name,
    db_password = "${var.service_name}-${var.environment}"
  })
}

resource "vault_generic_endpoint" "endpoint" {
  provider  = vault
  path      = "auth/userpass/users/${var.service_name}-${var.environment}"
  data_json = jsonencode({
    password = "${var.service_name}-${var.environment}",
    policies = ["default"]
  })
}

resource "docker_container" "container" {
  provider = docker
  image    = var.image
  name     = "${var.service_name}_${var.environment}"

  env = [
    "VAULT_ADDR=http://vault-${var.environment}:8200",
    "VAULT_USERNAME=${var.service_name}-${var.environment}",
    "VAULT_PASSWORD=${var.service_name}-${var.environment}",
    "ENVIRONMENT=${var.environment}"
  ]

  networks_advanced {
    name = var.network
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [vault_generic_endpoint.endpoint]

  dynamic "ports" {
    for_each = var.frontend_port != null ? [var.frontend_port] : []
    content {
      internal = 80
      external = ports.value
    }
  }
}
