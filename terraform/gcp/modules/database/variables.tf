/**
 * Cloud SQL Database Module Variables
 */

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

#===============================================================================
# Database Configuration
#===============================================================================

variable "database_version" {
  description = "Database version (POSTGRES_14, POSTGRES_15, MYSQL_8_0, etc.)"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Machine tier (db-f1-micro, db-g1-small, db-custom-1-3840, etc.)"
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 10
}

variable "disk_type" {
  description = "Disk type (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"
}

variable "disk_autoresize" {
  description = "Enable automatic disk size increase"
  type        = bool
  default     = true
}

variable "high_availability" {
  description = "Enable high availability (REGIONAL)"
  type        = bool
  default     = false
}

#===============================================================================
# Backup Configuration
#===============================================================================

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Backup start time (HH:MM format in UTC)"
  type        = string
  default     = "03:00"
}

variable "point_in_time_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "backup_retention_count" {
  description = "Number of backups to retain"
  type        = number
  default     = 7
}

#===============================================================================
# Network Configuration
#===============================================================================

variable "enable_public_ip" {
  description = "Assign a public IP address"
  type        = bool
  default     = false
}

variable "private_network" {
  description = "VPC network for private IP (if using VPC)"
  type        = string
  default     = null
}

variable "require_ssl" {
  description = "Require SSL for connections"
  type        = bool
  default     = true
}

variable "authorized_networks" {
  description = "List of authorized networks"
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

#===============================================================================
# Maintenance
#===============================================================================

variable "maintenance_window_day" {
  description = "Day of week for maintenance (1-7, 1=Monday)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Hour for maintenance window (0-23)"
  type        = number
  default     = 4
}

#===============================================================================
# Database Settings
#===============================================================================

variable "database_user" {
  description = "Database user name"
  type        = string
  default     = "postgres"
}

variable "database_charset" {
  description = "Database character set"
  type        = string
  default     = "UTF8"
}

variable "database_collation" {
  description = "Database collation"
  type        = string
  default     = "en_US.UTF8"
}

variable "database_flags" {
  description = "Database flags"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

#===============================================================================
# Monitoring
#===============================================================================

variable "query_insights_enabled" {
  description = "Enable Query Insights"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
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

variable "labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}
