/**
 * Outputs for Next.js on GCP Cloud Run
 */

#===============================================================================
# Cloud Run Service
#===============================================================================

output "service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.name
}

output "service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.uri
}

output "service_id" {
  description = "ID of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.id
}

output "service_location" {
  description = "Location of the Cloud Run service"
  value       = google_cloud_run_v2_service.app.location
}

#===============================================================================
# Artifact Registry
#===============================================================================

output "artifact_registry_repository" {
  description = "Artifact Registry repository name"
  value       = google_artifact_registry_repository.docker.repository_id
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

#===============================================================================
# Service Account
#===============================================================================

output "service_account_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloudrun.email
}

#===============================================================================
# Database (Conditional)
#===============================================================================

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = var.enable_cloud_sql ? module.database[0].connection_name : null
}

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = var.enable_cloud_sql ? module.database[0].instance_name : null
}

output "database_name" {
  description = "Database name"
  value       = var.enable_cloud_sql ? module.database[0].database_name : null
}

output "database_private_ip" {
  description = "Private IP address of the database"
  value       = var.enable_cloud_sql ? module.database[0].private_ip_address : null
}

#===============================================================================
# Load Balancer (Conditional)
#===============================================================================

output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = var.enable_load_balancer ? google_compute_global_address.lb_ip[0].address : null
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = var.enable_load_balancer ? "http://${google_compute_global_address.lb_ip[0].address}" : null
}

#===============================================================================
# VPC (Conditional)
#===============================================================================

output "vpc_network" {
  description = "VPC network name"
  value       = var.enable_vpc ? google_compute_network.vpc[0].name : null
}

output "vpc_connector_id" {
  description = "VPC connector ID"
  value       = var.enable_vpc ? google_vpc_access_connector.connector[0].id : null
}

#===============================================================================
# Deployment Commands
#===============================================================================

output "deployment_commands" {
  description = "Commands to deploy the application"
  value = {
    docker_auth  = "gcloud auth configure-docker ${var.region}-docker.pkg.dev"
    docker_build = "docker build -t ${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}/app:latest ."
    docker_push  = "docker push ${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}/app:latest"
    deploy       = "gcloud run services update ${google_cloud_run_v2_service.app.name} --region ${var.region} --image ${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}/app:latest"
  }
}

#===============================================================================
# Monitoring URLs
#===============================================================================

output "monitoring_urls" {
  description = "URLs for monitoring and logs"
  value = {
    cloud_run_console = "https://console.cloud.google.com/run/detail/${var.region}/${google_cloud_run_v2_service.app.name}/metrics?project=${var.gcp_project_id}"
    logs_explorer     = "https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloud_run_revision%22%0Aresource.labels.service_name%3D%22${google_cloud_run_v2_service.app.name}%22?project=${var.gcp_project_id}"
    monitoring        = "https://console.cloud.google.com/monitoring?project=${var.gcp_project_id}"
  }
}

#===============================================================================
# Summary
#===============================================================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    project_name         = var.project_name
    environment          = var.environment
    gcp_project_id       = var.gcp_project_id
    region               = var.region
    service_url          = google_cloud_run_v2_service.app.uri
    load_balancer_url    = var.enable_load_balancer ? "http://${google_compute_global_address.lb_ip[0].address}" : null
    artifact_registry    = "${var.region}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.docker.repository_id}"
    min_instances        = var.min_instances
    max_instances        = var.max_instances
    cpu                  = var.app_cpu
    memory               = var.app_memory
    database_enabled     = var.enable_cloud_sql
    vpc_enabled          = var.enable_vpc
    public_access        = var.allow_public_access
    scale_to_zero        = var.min_instances == 0
  }
}
