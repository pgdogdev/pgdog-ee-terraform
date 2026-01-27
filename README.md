# PgDog EE Terraform Module

Terraform module for deploying PgDog Enterprise Edition on AWS with Kubernetes.

## Features

- RDS PostgreSQL database with storage autoscaling
- PgDog Control Plane (Helm chart)
- PgDog Proxy (Helm chart)
- nginx-ingress-controller (optional)
- cert-manager with LetsEncrypt (optional)

## Usage

```hcl
module "pgdog" {
  source = "github.com/pgdogdev/pgdog-ee-terraform"

  # Required
  db_identifier        = "pgdog-production"
  db_subnet_group_name = "my-db-subnet-group"
  vpc_id               = "vpc-xxxxxxxxx"
  pgdog_version        = "1.0.0"
  pgdog_ingress_host   = "pgdog.example.com"

  pgdog_values = file("${path.module}/values/pgdog.yaml")

  # Environment variables (merged with auto-generated DATABASE_URL, SESSION_KEY)
  pgdog_control_env = {
    GOOGLE_CLIENT_ID     = var.google_client_id
    GOOGLE_CLIENT_SECRET = var.google_client_secret
  }

  tags = {
    Environment = "production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| helm | >= 2.0 |
| kubectl | >= 1.14 |
| random | >= 3.0 |

## Providers

- `hashicorp/aws`
- `hashicorp/helm`
- `hashicorp/random`
- `gavinbunney/kubectl`

## Variables

### Required

| Name | Description | Type |
|------|-------------|------|
| `db_identifier` | Identifier for the RDS instance | `string` |
| `db_subnet_group_name` | DB subnet group name | `string` |
| `vpc_id` | VPC ID where the RDS instance will be created | `string` |
| `pgdog_version` | PgDog image tag version | `string` |
| `pgdog_ingress_host` | Ingress hostname for pgdog-control | `string` |

### Optional - AWS/RDS

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `aws_region` | AWS region | `string` | `"us-east-1"` |
| `postgres_version` | PostgreSQL engine version | `string` | `"18"` |
| `db_name` | Name of the database to create | `string` | `"pgdog-ee"` |
| `db_username` | Master username for the database | `string` | `"postgres"` |
| `db_password` | Master password (generated if not provided) | `string` | `null` |
| `db_backup_retention_period` | Backup retention period in days | `number` | `7` |
| `db_skip_final_snapshot` | Skip final snapshot when destroying | `bool` | `false` |
| `tags` | Tags to apply to resources | `map(string)` | `{}` |

### Optional - Kubernetes/Helm

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `pgdog_namespace` | Kubernetes namespace for pgdog | `string` | `"pgdog-cloud"` |
| `pgdog_redis_memory` | Memory allocation for Redis | `string` | `"128Mi"` |
| `pgdog_control_env` | Additional env vars for pgdog-control (merged with DATABASE_URL, SESSION_KEY) | `map(string)` | `{}` |
| `pgdog_control_values` | Additional Helm values for pgdog-control (YAML string) | `string` | `""` |
| `pgdog_values` | Additional Helm values for pgdog (YAML string) | `string` | `""` |

### Optional - Infrastructure

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `install_ingress_nginx` | Install nginx-ingress-controller | `bool` | `false` |
| `install_cert_manager` | Install cert-manager and LetsEncrypt ClusterIssuer | `bool` | `false` |
| `letsencrypt_email` | Email for LetsEncrypt notifications | `string` | `"founders@pgdog.dev"` |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `db_endpoint` | RDS instance endpoint (host:port) | No |
| `db_address` | RDS instance address (host only) | No |
| `db_port` | RDS instance port | No |
| `db_password` | RDS instance password | Yes |
| `db_url` | PostgreSQL connection URL | Yes |

## RDS Configuration

The module creates an RDS PostgreSQL instance with:

- **Instance class**: db.m5.large
- **Storage**: 100GB initial (gp3)
- **Max storage**: 1TB (autoscaling enabled)
- **Multi-AZ**: Disabled

A security group is automatically created allowing PostgreSQL traffic (port 5432) from within the VPC only.

## Helm Charts

### pgdog-control

Installed from `https://helm-ee.pgdog.dev`. Automatically configured with:

- `DATABASE_URL` - Connection string to RDS
- `SESSION_KEY` - Auto-generated 64-byte key for Actix Web sessions

### pgdog

Installed from `https://helm.pgdog.dev`.

## Passing Custom Values

### Environment Variables

Use `pgdog_control_env` for env vars (merged with auto-generated `DATABASE_URL` and `SESSION_KEY`):

```hcl
module "pgdog" {
  # ...

  pgdog_control_env = {
    GOOGLE_CLIENT_ID     = var.google_client_id
    GOOGLE_CLIENT_SECRET = var.google_client_secret
  }
}
```

### Helm Values

```hcl
module "pgdog" {
  # ...

  # From file
  pgdog_control_values = file("${path.module}/control-values.yaml")

  # Inline
  pgdog_values = yamlencode({
    replicas = 3
    resources = {
      limits = {
        memory = "512Mi"
      }
    }
  })
}
```
