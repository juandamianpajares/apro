/**
 * Cloud SQL Database Module Outputs
 */

output "instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "connection_name" {
  description = "Connection name for Cloud SQL proxy"
  value       = google_sql_database_instance.main.connection_name
}

output "database_name" {
  description = "Name of the database"
  value       = google_sql_database.database.name
}

output "database_user" {
  description = "Database user name"
  value       = google_sql_user.user.name
  sensitive   = true
}

output "database_password" {
  description = "Database password"
  value       = google_sql_user.user.password
  sensitive   = true
}

output "private_ip_address" {
  description = "Private IP address"
  value       = try(google_sql_database_instance.main.private_ip_address, null)
}

output "public_ip_address" {
  description = "Public IP address"
  value       = try(google_sql_database_instance.main.public_ip_address, null)
}

output "self_link" {
  description = "Self link to the instance"
  value       = google_sql_database_instance.main.self_link
}

output "service_account_email" {
  description = "Service account email address"
  value       = google_sql_database_instance.main.service_account_email_address
}

output "connection_string" {
  description = "Connection string for the database"
  value       = "postgresql://${google_sql_user.user.name}@/${google_sql_database.database.name}?host=/cloudsql/${google_sql_database_instance.main.connection_name}"
  sensitive   = true
}
