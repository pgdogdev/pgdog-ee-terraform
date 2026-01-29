variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# RDS Variables
variable "create_rds" {
  description = "Whether to create the RDS instance"
  type        = bool
  default     = true
}

variable "external_database_url" {
  description = "External database URL (required if create_rds is false)"
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition     = var.create_rds || var.external_database_url != null
    error_message = "external_database_url must be provided when create_rds is false"
  }
}

variable "db_identifier" {
  description = "Identifier for the RDS instance (required if create_rds is true)"
  type        = string
  default     = null

  validation {
    condition     = !var.create_rds || var.db_identifier != null
    error_message = "db_identifier must be provided when create_rds is true"
  }
}

variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "18"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "postgres"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for the database (generated if not provided)"
  type        = string
  sensitive   = true
  default     = null
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.small"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "DB subnet group name (required if create_rds is true)"
  type        = string
  default     = null

  validation {
    condition     = !var.create_rds || var.db_subnet_group_name != null
    error_message = "db_subnet_group_name must be provided when create_rds is true"
  }
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created (required if create_rds is true)"
  type        = string
  default     = null

  validation {
    condition     = !var.create_rds || var.vpc_id != null
    error_message = "vpc_id must be provided when create_rds is true"
  }
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying the database"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Helm Variables
variable "pgdog_namespace" {
  description = "Kubernetes namespace for pgdog-control"
  type        = string
  default     = "pgdog-cloud"
}

variable "pgdog_version" {
  description = "Default PgDog version (used for control, blue, and green unless overridden)"
  type        = string
  default     = null
}

variable "pgdog_control_version" {
  description = "PgDog control image tag version (defaults to pgdog_version)"
  type        = string
  default     = null
}

variable "pgdog_blue_version" {
  description = "PgDog blue deployment chart version (defaults to pgdog_version)"
  type        = string
  default     = null
}

variable "pgdog_green_version" {
  description = "PgDog green deployment chart version (defaults to pgdog_version)"
  type        = string
  default     = null
}

variable "pgdog_ingress_host" {
  description = "Ingress hostname for pgdog-control"
  type        = string
}

variable "pgdog_ingress_tls_enabled" {
  description = "Enable TLS for pgdog-control ingress"
  type        = bool
  default     = true
}

variable "pgdog_ingress_cluster_issuer" {
  description = "Cert-manager ClusterIssuer for pgdog-control ingress (requires tls enabled)"
  type        = string
  default     = "letsencrypt-prod"
}

variable "pgdog_ingress_ssl_redirect" {
  description = "Redirect HTTP to HTTPS for pgdog-control ingress (requires tls enabled)"
  type        = bool
  default     = true
}

variable "pgdog_redis_memory" {
  description = "Memory allocation for Redis"
  type        = string
  default     = "128Mi"
}

variable "pgdog_control_values" {
  description = "Additional Helm values for pgdog-control chart (YAML string)"
  type        = string
  default     = ""
}

variable "pgdog_control_env" {
  description = "Additional environment variables for pgdog-control (merged with DATABASE_URL and SESSION_KEY)"
  type        = map(string)
  default     = {}
}

variable "pgdog_blue_token" {
  description = "API token for pgdog-blue (generated if not provided)"
  type        = string
  default     = null
}

variable "pgdog_green_token" {
  description = "API token for pgdog-green (generated if not provided)"
  type        = string
  default     = null
}

variable "pgdog_token_emails" {
  description = "List of emails to assign to both blue and green tokens"
  type        = list(string)
  default     = []
}

variable "pgdog_blue_values" {
  description = "Additional Helm values for pgdog-blue chart (YAML string)"
  type        = string
  default     = ""
}

variable "pgdog_green_values" {
  description = "Additional Helm values for pgdog-green chart (YAML string)"
  type        = string
  default     = ""
}

# Blue/Green DNS Variables
variable "pgdog_create_dns_record" {
  description = "Whether to create the Route53 DNS record for pgdog"
  type        = bool
  default     = false
}

variable "pgdog_active_deployment" {
  description = "Active deployment for DNS routing (blue or green)"
  type        = string
  default     = "blue"
  validation {
    condition     = contains(["blue", "green"], var.pgdog_active_deployment)
    error_message = "pgdog_active_deployment must be 'blue' or 'green'"
  }
}

variable "pgdog_route53_zone_id" {
  description = "Route53 hosted zone ID for pgdog DNS record"
  type        = string
  default     = ""
}

variable "pgdog_route53_record_name" {
  description = "DNS record name for pgdog (e.g., pgdog.example.com)"
  type        = string
  default     = ""
}

variable "pgdog_blue_endpoint" {
  description = "Endpoint for blue deployment (e.g., load balancer DNS name)"
  type        = string
  default     = ""
}

variable "pgdog_green_endpoint" {
  description = "Endpoint for green deployment (e.g., load balancer DNS name)"
  type        = string
  default     = ""
}

# Cert Manager Variables
variable "install_ingress_nginx" {
  description = "Install nginx-ingress-controller"
  type        = bool
  default     = false
}

variable "install_cert_manager" {
  description = "Install cert-manager and LetsEncrypt ClusterIssuer"
  type        = bool
  default     = false
}

variable "letsencrypt_email" {
  description = "Email address for LetsEncrypt certificate notifications"
  type        = string
  default     = "founders@pgdog.dev"
}

variable "ingress_ssl_redirect" {
  description = "Redirect HTTP to HTTPS globally"
  type        = bool
  default     = true
}

# Helm Chart Versions
variable "pgdog_blue_helm_chart_version" {
  description = "PgDog Helm chart version for blue deployment (uses latest if not specified)"
  type        = string
  default     = null
}

variable "pgdog_green_helm_chart_version" {
  description = "PgDog Helm chart version for green deployment (uses latest if not specified)"
  type        = string
  default     = null
}

variable "pgdog_control_helm_chart_version" {
  description = "PgDog Control Helm chart version (uses latest if not specified)"
  type        = string
  default     = null
}

variable "ingress_nginx_chart_version" {
  description = "NGINX Ingress Controller Helm chart version (uses latest if not specified)"
  type        = string
  default     = null
}

variable "cert_manager_chart_version" {
  description = "Cert Manager Helm chart version (uses latest if not specified)"
  type        = string
  default     = null
}
