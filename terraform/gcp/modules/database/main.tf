/**
 * Cloud SQL Database Module
 * PostgreSQL or MySQL managed database
 */

#===============================================================================
# Cloud SQL Instance
#===============================================================================

resource "google_sql_database_instance" "main" {
  project          = var.gcp_project_id
  name             = "${var.project_name}-${var.environment}-db"
  database_version = var.database_version
  region           = var.region

  settings {
    tier              = var.tier
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    disk_autoresize   = var.disk_autoresize
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"

    # Backup configuration
    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_enabled
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = var.backup_retention_count
        retention_unit   = "COUNT"
      }
    }

    # IP configuration
    ip_configuration {
      ipv4_enabled    = var.enable_public_ip
      private_network = var.private_network
      require_ssl     = var.require_ssl

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    # Maintenance window
    maintenance_window {
      day          = var.maintenance_window_day
      hour         = var.maintenance_window_hour
      update_track = "stable"
    }

    # Insights
    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
    }

    # Database flags
    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    # User labels
    user_labels = var.labels
  }

  deletion_protection = var.deletion_protection

  lifecycle {
    ignore_changes = [
      settings[0].disk_size
    ]
  }
}

#===============================================================================
# Database
#===============================================================================

resource "google_sql_database" "database" {
  project  = var.gcp_project_id
  name     = replace(var.project_name, "-", "_")
  instance = google_sql_database_instance.main.name
  charset  = var.database_charset
  collation = var.database_collation
}

#===============================================================================
# Database User
#===============================================================================

resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "user" {
  project  = var.gcp_project_id
  name     = var.database_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}

#===============================================================================
# Monitoring Alerts
#===============================================================================

# Alert for high CPU utilization
resource "google_monitoring_alert_policy" "cpu_high" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment} - Database CPU High"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization above 80%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.gcp_project_id}:${google_sql_database_instance.main.name}\" AND metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert for high memory utilization
resource "google_monitoring_alert_policy" "memory_high" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment} - Database Memory High"
  combiner     = "OR"

  conditions {
    display_name = "Memory utilization above 90%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.gcp_project_id}:${google_sql_database_instance.main.name}\" AND metric.type=\"cloudsql.googleapis.com/database/memory/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.9

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert for disk utilization
resource "google_monitoring_alert_policy" "disk_high" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment} - Database Disk High"
  combiner     = "OR"

  conditions {
    display_name = "Disk utilization above 85%"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.gcp_project_id}:${google_sql_database_instance.main.name}\" AND metric.type=\"cloudsql.googleapis.com/database/disk/utilization\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.85

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert for instance state (down)
resource "google_monitoring_alert_policy" "instance_down" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment} - Database Instance Down"
  combiner     = "OR"

  conditions {
    display_name = "Instance is not running"

    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND resource.labels.database_id=\"${var.gcp_project_id}:${google_sql_database_instance.main.name}\" AND metric.type=\"cloudsql.googleapis.com/database/up\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  alert_strategy {
    auto_close = "300s"
  }
}
