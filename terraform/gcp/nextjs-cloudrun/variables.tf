/**
 * Variables for Next.js on GCP Cloud Run
 */

#===============================================================================
# General
#===============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Additional labels for all resources"
  type        = map(string)
  default     = {}
}

#===============================================================================
# Networking
#===============================================================================

variable "enable_vpc" {
  description = "Enable VPC and VPC Connector for Cloud Run"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for VPC subnet"
  type        = string
  default     = "10.8.0.0/28"
}

variable "vpc_connector_cidr" {
  description = "CIDR range for VPC Access Connector"
  type        = string
  default     = "10.8.1.0/28"
}

#===============================================================================
# Application
#===============================================================================

variable "app_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 3000
}

variable "app_cpu" {
  description = "CPU allocation (e.g., '1' for 1 vCPU, '2' for 2 vCPUs)"
  type        = string
  default     = "1"

  validation {
    condition     = contains(["1", "2", "4", "8"], var.app_cpu)
    error_message = "CPU must be 1, 2, 4, or 8."
  }
}

variable "app_memory" {
  description = "Memory allocation (e.g., '512Mi', '1Gi', '2Gi')"
  type        = string
  default     = "512Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.app_memory))
    error_message = "Memory must be in format like '512Mi' or '1Gi'."
  }
}

variable "min_instances" {
  description = "Minimum number of instances (0 for scale to zero)"
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances >= 0 && var.min_instances <= 100
    error_message = "Min instances must be between 0 and 100."
  }
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 1000
    error_message = "Max instances must be between 1 and 1000."
  }
}

variable "cpu_throttling" {
  description = "Throttle CPU when idle (saves costs)"
  type        = bool
  default     = true
}

variable "startup_cpu_boost" {
  description = "Boost CPU during startup"
  type        = bool
  default     = true
}

variable "request_timeout" {
  description = "Request timeout in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.request_timeout >= 1 && var.request_timeout <= 3600
    error_message = "Timeout must be between 1 and 3600 seconds."
  }
}

variable "enable_session_affinity" {
  description = "Enable session affinity (sticky sessions)"
  type        = bool
  default     = false
}

#===============================================================================
# Access Control
#===============================================================================

variable "allow_public_access" {
  description = "Allow public access to Cloud Run service (allUsers)"
  type        = bool
  default     = true
}

#===============================================================================
# Load Balancer
#===============================================================================

variable "enable_load_balancer" {
  description = "Enable Cloud Load Balancer (for custom domain)"
  type        = bool
  default     = false
}

#===============================================================================
# Database
#===============================================================================

variable "enable_cloud_sql" {
  description = "Enable Cloud SQL database"
  type        = bool
  default     = false
}

variable "db_version" {
  description = "Database version (POSTGRES_14, POSTGRES_15, MYSQL_8_0)"
  type        = string
  default     = "POSTGRES_15"
}

variable "db_tier" {
  description = "Database tier (db-f1-micro, db-g1-small, db-custom-1-3840)"
  type        = string
  default     = "db-f1-micro"
}

variable "db_disk_size" {
  description = "Database disk size in GB"
  type        = number
  default     = 10
}

variable "db_disk_type" {
  description = "Database disk type (PD_SSD or PD_HDD)"
  type        = string
  default     = "PD_SSD"

  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.db_disk_type)
    error_message = "Disk type must be PD_SSD or PD_HDD."
  }
}

variable "db_high_availability" {
  description = "Enable high availability for database"
  type        = bool
  default     = false
}

variable "db_backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "db_backup_start_time" {
  description = "Backup start time (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "db_point_in_time_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}

variable "db_flags" {
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

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring uptime checks and alerts"
  type        = bool
  default     = true
}

variable "notification_channels" {
  description = "List of notification channel IDs for alerts"
  type        = list(string)
  default     = []
}
