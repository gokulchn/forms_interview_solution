# Form3 Platform Interview – Terraform Refactor & Enhancement

## Overview

This project is a refactored version of the Form3 platform interview take-home assignment. The original Terraform codebase has been modularized to support cleaner structure, reusability, and better environment management (dev, staging, production). Additionally, a new `staging` environment has been implemented, and Vault has been integrated with proper policy and user provisioning using the `userpass` auth method.

## Architecture Diagram

```
                 +------------------+
                 |    Frontend      |
                 +------------------+
                          |
             +------------+-------------+
             |            |             |
     +--------------+ +-----------+ +-------------+
     |   Gateway    | |  Account  | |   Payment   |
     +--------------+ +-----------+ +-------------+

 Each connects to its env-specific Vault (dev/staging/prod)
 to fetch database credentials using userpass auth.
```

## Project Structure

```

├── modules/
│   ├── service/
│   │   └── main.tf
│   └── vault/
│       └── main.tf
├── services/
├── main.tf
├── variables.tf
├── outputs.tf
└── README.md
```

## Design Decisions

1. Modularization
Each microservice (e.g., payment, gateway, frontend, account) is implemented as a reusable module.

Allows isolated development, testing, and scalability of services.

Promotes DRY principles by reusing logic across environments with minimal duplication.

✅ 2. Environment Isolation

Each environment runs on separate Vault ports (8201, 8301, 8401) to prevent collision.

✅ 3. Vault Integration (userpass + policies)
userpass auth method is enabled per Vault instance for simplicity in local dev.

Fine-grained policies created for each service, restricting access to only necessary paths (e.g., secret/data/staging/payment).

Secrets access is environment-specific, limiting blast radius.

✅ 4. Dynamic Service Definition

Easily add/remove services without modifying module logic.

✅ 5. Consistent Naming Conventions
Container and Vault paths follow consistent <env>_<service> or secret/data/<env>/<service> patterns.

Enables easy debugging, logging, and traceability.

✅ 6. Vagrant + Docker Compose Integration
Local sandboxing using Vagrant simplifies onboarding.

Vault is bootstrapped inside Docker containers to simulate production Vault setups with minimal dependencies.

✅ 7. Least Privilege Principles
Vault policies are scoped strictly to the service and its environment.

No broad wildcard paths are used to enforce Zero Trust principles.

✅ 8. Local Development Friendliness
Devs can run vagrant up to simulate the entire infrastructure locally.

Fast feedback loop for Vault secret access and service testing.

✅ 9. Clear Separation of Concerns
Provider configuration, environment variables, and reusable logic are clearly split across files.

Terraform code can be extended to cloud platforms by replacing the Docker provider.

✅ 10. Readiness for Production Extensions
TLS not enabled yet, but infrastructure prepared to plug in with Vault’s TLS setup.

Can integrate AppRole or OIDC for secure and scalable authentication.

Remote state backend like GCS or S3 can be easily introduced in backend.tf.

## CI/CD Integration Strategy

The Terraform code is designed to integrate with standard CI/CD practices:

1. **Plan and Apply Jobs**:
   - Run `terraform init`, `plan`, and `apply` using GitHub Actions or GitLab CI.
   - Separate workflows for each environment (`dev`, `staging`, `prod`) based on branches or tags.

2. **Vault Secrets Preprovisioning**:
   - Add CI steps to authenticate and enable `userpass` method in Vault before Terraform provisioning.

3. **Validation & Linting**:
   - Include `tflint`, `checkov`, and `terraform validate` to ensure compliance and security.

## Production Considerations

Beyond the scope of this test, in a production setting, the following would be essential:

- **Remote State Backend**: Use a remote backend (e.g., Terraform Cloud, S3 with DynamoDB lock) instead of local state.
- **State Locking & Versioning**: Ensure state consistency in multi-engineer environments.
- **Secrets Handling**: Secure provisioning of secrets into Vault via automation (e.g., CI Vault injection, Boundary integration).
- **Logging and Monitoring**: Include Terraform plan logging, Vault audit logs, and monitoring of service health.
- **Container Hardening**: Add production-grade configurations (non-root, minimal base image, etc.).

## How to Add/Update/Remove Services

1. **To Add**:
   - Create a new module call under each environment block.
   - Add required Vault policy and user config for the new service.

2. **To Update**:
   - Modify the corresponding module's variables or template.
   - Update Terraform code, then run `terraform plan` and `apply`.

3. **To Remove**:
   - Comment/remove module block.
   - Run `terraform destroy -target=module.<env>.module.<service>`.

## Prerequisites

- Vagrant + Docker + Terraform installed.
- Run `vagrant up` to bootstrap the environment.

---

**Note**: Ensure Vault containers are initialized and unsealed. You may need to enable the `userpass` method and apply ACL policies using the root token manually before Terraform apply.

## Modular Structure
Each microservice (payment, account, gateway, frontend) is independently deployed via modules. This ensures better reusability and isolation of logic.

## Environment Isolation
Development, staging, and production use separate Vault instances and Terraform configurations to simulate realistic multi-env infrastructure separation.

## Service Discovery & Secrets Access
Services authenticate using Vault's userpass method to retrieve credentials for their respective paths (secret/data/<env>/<service>).

## Explicit Port Mapping
Vault instances are bound to separate localhost ports (8201, 8301, 8401) to enable local multi-instance support without port conflict.
