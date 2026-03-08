output "db_endpoint" {
  description = "RDS endpoint — use in Spring Boot datasource URL"
  value       = aws_db_instance.main.endpoint
}

output "db_host" {
  description = "Hostname only (without port) — for JDBC URL construction"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}