/**
 * Outputs for Next.js on AWS ECS Fargate
 */

#===============================================================================
# Networking
#===============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

#===============================================================================
# Load Balancer
#===============================================================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}

#===============================================================================
# ECS
#===============================================================================

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

#===============================================================================
# ECR
#===============================================================================

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.app.arn
}

#===============================================================================
# CloudWatch
#===============================================================================

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.arn
}

#===============================================================================
# Security Groups
#===============================================================================

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

#===============================================================================
# Database (Conditional)
#===============================================================================

output "database_endpoint" {
  description = "Database endpoint"
  value       = var.enable_rds ? module.database[0].endpoint : null
}

output "database_name" {
  description = "Database name"
  value       = var.enable_rds ? module.database[0].database_name : null
}

output "database_port" {
  description = "Database port"
  value       = var.enable_rds ? module.database[0].port : null
}

#===============================================================================
# Deployment Information
#===============================================================================

output "deployment_commands" {
  description = "Commands to deploy the application"
  value = {
    docker_login = "aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.app.repository_url}"
    docker_build = "docker build -t ${aws_ecr_repository.app.repository_url}:latest ."
    docker_push  = "docker push ${aws_ecr_repository.app.repository_url}:latest"
    update_service = "aws ecs update-service --cluster ${aws_ecs_cluster.main.name} --service ${aws_ecs_service.app.name} --force-new-deployment --region ${var.region}"
  }
}

output "monitoring_urls" {
  description = "URLs for monitoring and logs"
  value = {
    ecs_console      = "https://console.aws.amazon.com/ecs/home?region=${var.region}#/clusters/${aws_ecs_cluster.main.name}/services"
    cloudwatch_logs  = "https://console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/${replace(aws_cloudwatch_log_group.app.name, "/", "$252F")}"
    alb_console      = "https://console.aws.amazon.com/ec2/v2/home?region=${var.region}#LoadBalancers:search=${aws_lb.main.arn}"
  }
}

#===============================================================================
# Summary
#===============================================================================

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    project_name     = var.project_name
    environment      = var.environment
    region           = var.region
    application_url  = "http://${aws_lb.main.dns_name}"
    ecr_repository   = aws_ecr_repository.app.repository_url
    ecs_cluster      = aws_ecs_cluster.main.name
    ecs_service      = aws_ecs_service.app.name
    task_cpu         = var.app_cpu
    task_memory      = var.app_memory
    min_capacity     = var.min_count
    max_capacity     = var.max_count
    database_enabled = var.enable_rds
  }
}
