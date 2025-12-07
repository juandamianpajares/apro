/**
 * Variables for Next.js on AWS ECS Fargate
 */

#===============================================================================
# General
#===============================================================================

variable "project_name" {
  description = "Name of the project (used for resource naming)"
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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

#===============================================================================
# Networking
#===============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (required for Fargate)"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost optimization for non-prod)"
  type        = bool
  default     = true
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
  description = "CPU units for the task (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 512

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.app_cpu)
    error_message = "CPU must be a valid Fargate value: 256, 512, 1024, 2048, or 4096."
  }
}

variable "app_memory" {
  description = "Memory for the task in MB (must be compatible with CPU)"
  type        = number
  default     = 1024

  validation {
    condition     = var.app_memory >= 512 && var.app_memory <= 30720
    error_message = "Memory must be between 512 MB and 30720 MB."
  }
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "min_count" {
  description = "Minimum number of tasks (auto-scaling)"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of tasks (auto-scaling)"
  type        = number
  default     = 10
}

#===============================================================================
# Monitoring & Logging
#===============================================================================

variable "enable_container_insights" {
  description = "Enable Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

variable "enable_ecs_exec" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

#===============================================================================
# Database
#===============================================================================

variable "enable_rds" {
  description = "Enable RDS database"
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "Database engine (mysql, postgres)"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for database"
  type        = bool
  default     = false
}

variable "db_backup_retention_days" {
  description = "Database backup retention period"
  type        = number
  default     = 7
}

#===============================================================================
# SSL/TLS (Optional)
#===============================================================================

variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS (optional)"
  type        = string
  default     = ""
}
