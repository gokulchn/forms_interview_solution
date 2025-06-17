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
  environment  = "staging"
  network      = "vagrant_staging"
}

module "gateway" {
  source       = "../../modules/service"
  service_name = "gateway"
  image        = "form3tech-oss/platformtest-gateway"
  environment  = "staging"
  network      = "vagrant_staging"
}

module "payment" {
  source       = "../../modules/service"
  service_name = "payment"
  image        = "form3tech-oss/platformtest-payment"
  environment  = "staging"
  network      = "vagrant_staging"
}

module "frontend" {
  source        = "../../modules/service"
  service_name  = "frontend"
  image         = "nginx:latest"
  environment   = "staging"
  network       = "vagrant_staging"
  frontend_port = 4082
}
