#!/bin/bash
set -e

function wait_for_vault() {
  local port=$1
  until curl --silent http://localhost:${port}/v1/sys/health | grep '"initialized":true' > /dev/null; do
    echo "⏳ Waiting for Vault at port ${port}..."
    sleep 2
  done
}

function enable_userpass() {
  local port=$1
  if curl --silent http://localhost:${port}/v1/sys/auth | jq -e '."userpass/"' > /dev/null; then
    echo "✅ userpass already enabled on port ${port}"
  else
    echo "🔐 Enabling userpass on Vault at port ${port}..."
    curl --silent --request POST --data '{"type": "userpass"}' http://localhost:${port}/v1/sys/auth/userpass
  fi
}

# Install Docker Compose (v2+ CLI plugin style)
echo "🧩 Installing Docker Compose plugin..."
mkdir -p ~/.docker/cli-plugins
echo "🧩 Installing Docker Compose plugin..."
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose

echo "🔧 Starting Docker Compose"
docker-compose up -d

# Wait for Vault instances to be ready
wait_for_vault 8201
wait_for_vault 8301
wait_for_vault 8401

# Enable userpass on each Vault
enable_userpass 8201
enable_userpass 8301
enable_userpass 8401

# Run Terraform
cd /vagrant/tf
terraform init

echo "🔐 Enabling userpass auth on all Vault instances..."
curl --silent --request POST http://localhost:8201/v1/sys/auth/userpass -d '{"type":"userpass"}' || true
curl --silent --request POST http://localhost:8301/v1/sys/auth/userpass -d '{"type":"userpass"}' || true
curl --silent --request POST http://localhost:8401/v1/sys/auth/userpass -d '{"type":"userpass"}' || true
terraform apply -auto-approve


echo "🔐 Enabling userpass auth method on all Vault instances..."
export VAULT_ADDR=http://localhost:8201
vault login $VAULT_DEV_ROOT_TOKEN_ID
vault auth enable userpass || true

export VAULT_ADDR=http://localhost:8401
vault login $VAULT_DEV_ROOT_TOKEN_ID
vault auth enable userpass || true

export VAULT_ADDR=http://localhost:8301
vault login $VAULT_DEV_ROOT_TOKEN_ID
vault auth enable userpass || true
