# Output values

output "db_endpoint" {
  description = "RDS instance endpoint (null if create_rds is false)"
  value       = try(aws_db_instance.postgres[0].endpoint, null)
}

output "db_address" {
  description = "RDS instance address (null if create_rds is false)"
  value       = try(aws_db_instance.postgres[0].address, null)
}

output "db_port" {
  description = "RDS instance port (null if create_rds is false)"
  value       = try(aws_db_instance.postgres[0].port, null)
}

output "db_password" {
  description = "RDS instance password (null if create_rds is false)"
  value       = var.create_rds ? coalesce(var.db_password, random_password.db_password[0].result) : null
  sensitive   = true
}

output "db_url" {
  description = "PostgreSQL connection URL"
  value = var.create_rds ? (
    "postgres://${aws_db_instance.postgres[0].username}:${urlencode(coalesce(var.db_password, random_password.db_password[0].result))}@${aws_db_instance.postgres[0].endpoint}/${aws_db_instance.postgres[0].db_name}"
  ) : var.external_database_url
  sensitive = true
}

output "pgdog_blue_token" {
  description = "API token for pgdog-blue"
  value       = local.pgdog_blue_token
  sensitive   = true
}

output "pgdog_green_token" {
  description = "API token for pgdog-green"
  value       = local.pgdog_green_token
  sensitive   = true
}
