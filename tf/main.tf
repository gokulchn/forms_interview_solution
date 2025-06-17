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

provider "docker" {}

provider "vault" {
  alias   = "vault_dev"
  address = "http://localhost:8201"
  token   = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
}

provider "vault" {
  alias   = "vault_staging"
  address = "http://localhost:8401"
  token   = "abcdefab-1234-5678-90ab-cdef12345678"
}

provider "vault" {
  alias   = "vault_prod"
  address = "http://localhost:8301"
  token   = "083672fc-4471-4ec4-9b59-a285e463a973"
}

module "development" {
  source = "./environments/development"
  providers = {
    vault  = vault.vault_dev
    docker = docker
  }
}

module "staging" {
  source = "./environments/staging"
  providers = {
    vault  = vault.vault_staging
    docker = docker
  }
}

module "production" {
  source = "./environments/production"
  providers = {
    vault  = vault.vault_prod
    docker = docker
  }
}
