/**
 * APRO - Next.js on GCP Cloud Run
 * Production-ready serverless infrastructure
 * Auto-scaling, High Availability, Managed Services
 */

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Backend configuration (uncomment for remote state)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "apro/${var.project_name}/${var.environment}"
  # }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.region

  default_labels = merge(
    var.labels,
    {
      managed-by  = "apro-terraform"
      environment = var.environment
      project     = var.project_name
    }
  )
}

#===============================================================================
# Data Sources
#===============================================================================

data "google_project" "project" {
  project_id = var.gcp_project_id
}

#===============================================================================
# Enable Required APIs
#===============================================================================

resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "vpcaccess.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
  ])

  project = var.gcp_project_id
  service = each.value

  disable_on_destroy = false
}

#===============================================================================
# VPC Network (Optional - for VPC Connector)
#===============================================================================

resource "google_compute_network" "vpc" {
  count = var.enable_vpc ? 1 : 0

  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "subnet" {
  count = var.enable_vpc ? 1 : 0

  name          = "${var.project_name}-${var.environment}-subnet"
  ip_cidr_range = var.vpc_cidr
  region        = var.region
  network       = google_compute_network.vpc[0].id
  project       = var.gcp_project_id

  private_ip_google_access = true
}

# VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  count = var.enable_vpc ? 1 : 0

  name          = "${var.project_name}-${var.environment}-vpc-cx"
  project       = var.gcp_project_id
  region        = var.region
  network       = google_compute_network.vpc[0].name
  ip_cidr_range = var.vpc_connector_cidr

  depends_on = [
    google_project_service.required_apis,
    google_compute_subnetwork.subnet
  ]
}

#===============================================================================
# Artifact Registry (Docker Images)
#===============================================================================

resource "google_artifact_registry_repository" "docker" {
  project       = var.gcp_project_id
  location      = var.region
  repository_id = "${var.project_name}-${var.environment}"
  description   = "Docker repository for ${var.project_name} ${var.environment}"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-recent-images"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  depends_on = [google_project_service.required_apis]
}

#===============================================================================
# Service Account for Cloud Run
#===============================================================================

resource "google_service_account" "cloudrun" {
  project      = var.gcp_project_id
  account_id   = "${var.project_name}-${var.environment}-run"
  display_name = "Cloud Run service account for ${var.project_name}"
  description  = "Service account for Cloud Run service"
}

# Allow Cloud Run to access Secret Manager
resource "google_project_iam_member" "cloudrun_secrets" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow Cloud Run to access Cloud SQL
resource "google_project_iam_member" "cloudrun_sql" {
  count = var.enable_cloud_sql ? 1 : 0

  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

#===============================================================================
# Secrets Manager
#===============================================================================

# Database credentials (if Cloud SQL is enabled)
resource "random_password" "db_password" {
  count = var.enable_cloud_sql ? 1 : 0

  length  = 32
  special = true
}

resource "google_secret_manager_secret" "db_password" {
  count = var.enable_cloud_sql ? 1 : 0

  project   = var.gcp_project_id
  secret_id = "${var.project_name}-${var.environment}-db-password"

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret_version" "db_password" {
  count = var.enable_cloud_sql ? 1 : 0

  secret      = google_secret_manager_secret.db_password[0].id
  secret_data = random_password.db_password[0].result
}

#===============================================================================
# Cloud SQL Database (Optional)
#===============================================================================

module "database" {
  source = "../modules/database"
  count  = var.enable_cloud_sql ? 1 : 0

  project_name   = var.project_name
  environment    = var.environment
  gcp_project_id = var.gcp_project_id
  region         = var.region

  database_version = var.db_version
  tier             = var.db_tier
  disk_size        = var.db_disk_size
  disk_type        = var.db_disk_type

  high_availability     = var.db_high_availability
  backup_enabled        = var.db_backup_enabled
  backup_start_time     = var.db_backup_start_time
  point_in_time_enabled = var.db_point_in_time_enabled

  database_flags = var.db_flags

  labels = var.labels

  depends_on = [google_project_service.required_apis]
}

#===============================================================================
# Cloud Run Service
#===============================================================================

resource "google_cloud_run_v2_service" "app" {
  project  = var.gcp_project_id
  name     = "${var.project_name}-${var.environment}"
  location = var.region

  template {
    service_account = google_service_account.cloudrun.email

    # Scaling
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    # VPC Connector (if enabled)
    dynamic "vpc_access" {
      for_each = var.enable_vpc ? [1] : []
      content {
        connector = google_vpc_access_connector.connector[0].id
        egress    = "ALL_TRAFFIC"
      }
    }

    containers {
      # Initial image (will be replaced by actual deployment)
      image = "${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}/app:latest"

      # Resources
      resources {
        limits = {
          cpu    = var.app_cpu
          memory = var.app_memory
        }
        cpu_idle          = var.cpu_throttling
        startup_cpu_boost = var.startup_cpu_boost
      }

      # Port
      ports {
        container_port = var.app_port
      }

      # Environment variables
      env {
        name  = "NODE_ENV"
        value = var.environment == "production" ? "production" : "development"
      }

      env {
        name  = "PORT"
        value = tostring(var.app_port)
      }

      env {
        name  = "GCP_PROJECT"
        value = var.gcp_project_id
      }

      # Database connection (if Cloud SQL is enabled)
      dynamic "env" {
        for_each = var.enable_cloud_sql ? [1] : []
        content {
          name  = "DB_HOST"
          value = "/cloudsql/${module.database[0].connection_name}"
        }
      }

      dynamic "env" {
        for_each = var.enable_cloud_sql ? [1] : []
        content {
          name  = "DB_NAME"
          value = module.database[0].database_name
        }
      }

      dynamic "env" {
        for_each = var.enable_cloud_sql ? [1] : []
        content {
          name  = "DB_USER"
          value = "postgres"
        }
      }

      # Secret for database password
      dynamic "env" {
        for_each = var.enable_cloud_sql ? [1] : []
        content {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password[0].secret_id
              version = "latest"
            }
          }
        }
      }

      # Startup probe
      startup_probe {
        http_get {
          path = "/api/health"
          port = var.app_port
        }
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      # Liveness probe
      liveness_probe {
        http_get {
          path = "/api/health"
          port = var.app_port
        }
        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
      }
    }

    # Cloud SQL connection (if enabled)
    dynamic "volumes" {
      for_each = var.enable_cloud_sql ? [1] : []
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [module.database[0].connection_name]
        }
      }
    }

    # Execution environment
    timeout         = "${var.request_timeout}s"
    max_retries     = 0
    session_affinity = var.enable_session_affinity
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [
    google_project_service.required_apis,
    google_artifact_registry_repository.docker
  ]

  labels = var.labels
}

#===============================================================================
# Cloud Run IAM - Public Access
#===============================================================================

resource "google_cloud_run_service_iam_member" "public_access" {
  count = var.allow_public_access ? 1 : 0

  project  = google_cloud_run_v2_service.app.project
  location = google_cloud_run_v2_service.app.location
  service  = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

#===============================================================================
# Load Balancer (Optional - for custom domain)
#===============================================================================

# Reserve static IP
resource "google_compute_global_address" "lb_ip" {
  count = var.enable_load_balancer ? 1 : 0

  project = var.gcp_project_id
  name    = "${var.project_name}-${var.environment}-lb-ip"
}

# Backend service for Cloud Run
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  count = var.enable_load_balancer ? 1 : 0

  project               = var.gcp_project_id
  name                  = "${var.project_name}-${var.environment}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.app.name
  }
}

resource "google_compute_backend_service" "app" {
  count = var.enable_load_balancer ? 1 : 0

  project = var.gcp_project_id
  name    = "${var.project_name}-${var.environment}-backend"

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg[0].id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# URL Map
resource "google_compute_url_map" "app" {
  count = var.enable_load_balancer ? 1 : 0

  project         = var.gcp_project_id
  name            = "${var.project_name}-${var.environment}-lb"
  default_service = google_compute_backend_service.app[0].id
}

# HTTP(S) Proxy
resource "google_compute_target_http_proxy" "app" {
  count = var.enable_load_balancer ? 1 : 0

  project = var.gcp_project_id
  name    = "${var.project_name}-${var.environment}-http-proxy"
  url_map = google_compute_url_map.app[0].id
}

# Forwarding rule
resource "google_compute_global_forwarding_rule" "app" {
  count = var.enable_load_balancer ? 1 : 0

  project    = var.gcp_project_id
  name       = "${var.project_name}-${var.environment}-lb-rule"
  target     = google_compute_target_http_proxy.app[0].id
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip[0].address
}

#===============================================================================
# Cloud Monitoring - Uptime Check
#===============================================================================

resource "google_monitoring_uptime_check_config" "app" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment}-uptime"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/api/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = google_cloud_run_v2_service.app.uri
    }
  }
}

#===============================================================================
# Alert Policy - Service Down
#===============================================================================

resource "google_monitoring_alert_policy" "service_down" {
  count = var.enable_monitoring ? 1 : 0

  project      = var.gcp_project_id
  display_name = "${var.project_name}-${var.environment} - Service Down"
  combiner     = "OR"

  conditions {
    display_name = "Service uptime check failed"

    condition_threshold {
      filter          = "resource.type=\"uptime_url\" AND metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  alert_strategy {
    auto_close = "1800s"
  }

  notification_channels = var.notification_channels
}
