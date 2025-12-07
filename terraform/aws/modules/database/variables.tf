/**
 * Database Module Variables
 */

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

#===============================================================================
# Engine Configuration
#===============================================================================

variable "engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "mysql"

  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "Engine must be either mysql or postgres."
  }
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

#===============================================================================
# Storage
#===============================================================================

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling in GB"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional)"
  type        = string
  default     = null
}

#===============================================================================
# Database Configuration
#===============================================================================

variable "database_name" {
  description = "Name of the database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "parameters" {
  description = "Database parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#===============================================================================
# Network
#===============================================================================

variable "publicly_accessible" {
  description = "Make database publicly accessible"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone (only if not multi-AZ)"
  type        = string
  default     = null
}

#===============================================================================
# High Availability
#===============================================================================

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

#===============================================================================
# Backup & Maintenance
#===============================================================================

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "delete_automated_backups" {
  description = "Delete automated backups on instance deletion"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion (not recommended for production)"
  type        = bool
  default     = false
}

#===============================================================================
# Monitoring
#===============================================================================

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (error, general, slowquery for MySQL)"
  type        = list(string)
  default     = ["error", "general", "slowquery"]
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms trigger"
  type        = list(string)
  default     = []
}

#===============================================================================
# Protection
#===============================================================================

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

#===============================================================================
# Tags
#===============================================================================

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
