# Output values

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "db_address" {
  description = "RDS instance address"
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.postgres.port
}

output "db_password" {
  description = "RDS instance password"
  value       = coalesce(var.db_password, random_password.db_password.result)
  sensitive   = true
}

output "db_url" {
  description = "PostgreSQL connection URL"
  value       = "postgres://${aws_db_instance.postgres.username}:${urlencode(coalesce(var.db_password, random_password.db_password.result))}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}
