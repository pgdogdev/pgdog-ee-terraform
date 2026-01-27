variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# RDS Variables
variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "18"
}

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "pgdog-ee"
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

variable "db_subnet_group_name" {
  description = "DB subnet group name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be created"
  type        = string
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
  description = "PgDog image tag version"
  type        = string
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

variable "pgdog_values" {
  description = "Additional Helm values for pgdog chart (YAML string)"
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
