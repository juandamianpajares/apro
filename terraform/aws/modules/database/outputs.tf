/**
 * Database Module Outputs
 */

output "instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "endpoint" {
  description = "Connection endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "Hostname of the RDS instance"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "master_username" {
  description = "Master username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "engine" {
  description = "Database engine"
  value       = aws_db_instance.main.engine
}

output "engine_version" {
  description = "Database engine version"
  value       = aws_db_instance.main.engine_version
}

output "resource_id" {
  description = "Resource ID of the RDS instance"
  value       = aws_db_instance.main.resource_id
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_db_instance.main.availability_zone
}

output "multi_az" {
  description = "Whether Multi-AZ is enabled"
  value       = aws_db_instance.main.multi_az
}

output "backup_retention_period" {
  description = "Backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secrets_manager_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "connection_string" {
  description = "Connection string for the database"
  value       = "${var.engine}://${var.master_username}@${aws_db_instance.main.endpoint}/${var.database_name}"
  sensitive   = true
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = {
    cpu         = aws_cloudwatch_metric_alarm.database_cpu.arn
    memory      = aws_cloudwatch_metric_alarm.database_memory.arn
    storage     = aws_cloudwatch_metric_alarm.database_storage.arn
    connections = aws_cloudwatch_metric_alarm.database_connections.arn
  }
}
