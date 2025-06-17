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

resource "vault_audit" "audit" {
  provider = vault
  type     = "file"
  options  = {
    file_path = "/vault/logs/audit"
  }
}

module "account" {
  source       = "../../modules/service"
  service_name = "account"
  image        = "form3tech-oss/platformtest-account"
  environment  = "production"
  network      = "vagrant_production"
}

module "gateway" {
  source       = "../../modules/service"
  service_name = "gateway"
  image        = "form3tech-oss/platformtest-gateway"
  environment  = "production"
  network      = "vagrant_production"
}

module "payment" {
  source       = "../../modules/service"
  service_name = "payment"
  image        = "form3tech-oss/platformtest-payment"
  environment  = "production"
  network      = "vagrant_production"
}

module "frontend" {
  source        = "../../modules/service"
  service_name  = "frontend"
  image         = "nginx:1.22.0-alpine"
  environment   = "production"
  network       = "vagrant_production"
  frontend_port = 4081
}
