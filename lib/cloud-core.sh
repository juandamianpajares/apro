#!/bin/bash

#===============================================================================
# Cloud Core - Multi-Cloud Infrastructure Management
# Handles AWS, GCP, and local deployments
#===============================================================================

# Colores (si no están definidos)
readonly GREEN=${GREEN:-'\033[0;32m'}
readonly RED=${RED:-'\033[0;31m'}
readonly BLUE=${BLUE:-'\033[0;34m'}
readonly CYAN=${CYAN:-'\033[0;36m'}
readonly YELLOW=${YELLOW:-'\033[1;33m'}
readonly BOLD=${BOLD:-'\033[1m'}
readonly NC=${NC:-'\033[0m'}

# Paths
APRO_ROOT="${APRO_ROOT:-/home/user/apro}"
TF_DIR="$APRO_ROOT/terraform"
CONFIG_FILE="${CONFIG_FILE:-.apro.yml}"

#===============================================================================
# Logging Functions
#===============================================================================

log() {
    echo -e "${GREEN}✓ $1${NC}"
}

error() {
    echo -e "${RED}✗ ERROR: $1${NC}" >&2
}

info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

success() {
    echo -e "${GREEN}${BOLD}✓✓✓ $1${NC}"
}

#===============================================================================
# Prerequisites Check
#===============================================================================

check_terraform() {
    if ! command -v terraform &> /dev/null; then
        error "Terraform no está instalado"
        echo ""
        info "Instala Terraform:"
        echo "  https://developer.hashicorp.com/terraform/downloads"
        echo ""
        info "Debian/Ubuntu:"
        echo "  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg"
        echo "  echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com \$(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list"
        echo "  sudo apt update && sudo apt install terraform"
        exit 1
    fi
    log "Terraform $(terraform version -json | jq -r '.terraform_version') detectado"
}

check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        error "AWS CLI no está instalado"
        echo ""
        info "Instala AWS CLI:"
        echo "  curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\""
        echo "  unzip awscliv2.zip"
        echo "  sudo ./aws/install"
        exit 1
    fi

    if ! aws sts get-caller-identity &> /dev/null; then
        error "AWS CLI no está configurado"
        echo ""
        info "Configura AWS CLI:"
        echo "  aws configure"
        exit 1
    fi

    log "AWS CLI configurado (Account: $(aws sts get-caller-identity --query Account --output text))"
}

check_gcloud_cli() {
    if ! command -v gcloud &> /dev/null; then
        error "Google Cloud SDK no está instalado"
        echo ""
        info "Instala gcloud:"
        echo "  https://cloud.google.com/sdk/docs/install"
        exit 1
    fi

    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
        error "gcloud no está autenticado"
        echo ""
        info "Autentica gcloud:"
        echo "  gcloud auth login"
        echo "  gcloud auth application-default login"
        exit 1
    fi

    log "gcloud configurado (Project: $(gcloud config get-value project 2>/dev/null || echo 'not set'))"
}

#===============================================================================
# Configuration Management
#===============================================================================

config_init() {
    local project_dir="${1:-.}"
    local config_file="$project_dir/$CONFIG_FILE"

    if [ -f "$config_file" ]; then
        warn "apro.yml ya existe"
        read -p "¿Sobrescribir? (y/N): " -r overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            return 0
        fi
    fi

    cat > "$config_file" <<'EOF'
# APRO Configuration File
# Multi-Cloud Infrastructure Configuration

project:
  name: my-app
  type: nextjs  # nextjs, laravel, nodejs, python, go
  version: 1.0.0

providers:
  # AWS Configuration
  aws:
    enabled: false
    region: us-east-1
    profile: default  # AWS CLI profile

    compute:
      service: ecs-fargate  # ecs-fargate, ecs-ec2, lambda
      min_instances: 1
      max_instances: 10
      cpu: 256      # 256, 512, 1024, 2048, 4096
      memory: 512   # MB

    database:
      engine: mysql  # mysql, postgres
      instance_class: db.t3.micro
      allocated_storage: 20  # GB
      multi_az: false

    cache:
      enabled: false
      engine: redis
      node_type: cache.t3.micro

    networking:
      vpc_cidr: "10.0.0.0/16"
      availability_zones: 2

  # GCP Configuration
  gcp:
    enabled: false
    project_id: ""
    region: us-central1

    compute:
      service: cloud-run  # cloud-run, gke
      min_instances: 0
      max_instances: 10
      cpu: 1
      memory: 512Mi

    database:
      tier: db-f1-micro  # db-f1-micro, db-g1-small, etc.
      storage_size: 10  # GB
      high_availability: false

    cache:
      enabled: false
      tier: BASIC
      memory_size_gb: 1

  # Local Development (Docker)
  local:
    enabled: true
    docker_compose: docker-compose.dev.yml

environments:
  dev:
    provider: local
    auto_deploy: false

  staging:
    provider: aws  # or gcp
    auto_deploy: true
    branch: develop

  production:
    provider: aws  # or gcp
    auto_deploy: false
    branch: main
    require_approval: true

# CI/CD Configuration
ci_cd:
  enabled: true
  platform: github-actions  # github-actions, gitlab-ci, jenkins

  on_push:
    - lint
    - test
    - build

  on_pr:
    - lint
    - test

  on_merge_to_main:
    - deploy_staging

  on_tag:
    - deploy_production

# Monitoring & Observability
monitoring:
  enabled: true

  aws:
    cloudwatch: true
    xray: false

  gcp:
    cloud_monitoring: true
    cloud_trace: false

  alerts:
    email: []
    slack_webhook: ""

# Secrets Management
secrets:
  provider: aws-secrets-manager  # aws-secrets-manager, gcp-secret-manager, vault
  auto_rotate: false

# Backup & Disaster Recovery
backup:
  enabled: true
  retention_days: 30
  schedule: "0 2 * * *"  # Daily at 2 AM

# Cost Optimization
cost_optimization:
  enabled: true
  auto_shutdown_dev: true  # Shutdown dev environments at night
  shutdown_schedule: "0 22 * * *"  # 10 PM
  startup_schedule: "0 8 * * 1-5"  # 8 AM weekdays
EOF

    log "Configuración creada: $config_file"
    echo ""
    info "Edita el archivo con tus configuraciones:"
    echo "  nano $config_file"
    echo ""
    info "Luego ejecuta:"
    echo "  apro init --provider=aws|gcp"
}

config_show() {
    local config_file="${CONFIG_FILE}"

    if [ ! -f "$config_file" ]; then
        warn "No existe $config_file"
        info "Ejecuta: apro config init"
        return 1
    fi

    cat "$config_file"
}

config_set() {
    local key="$1"
    local value="$2"

    if [ -z "$key" ] || [ -z "$value" ]; then
        error "Usage: apro config set <key> <value>"
        return 1
    fi

    # TODO: Implement YAML manipulation
    warn "config set aún no implementado"
    info "Edita manualmente: $CONFIG_FILE"
}

#===============================================================================
# Cloud Init - Initialize Infrastructure
#===============================================================================

cloud_init() {
    info "Inicializando infraestructura cloud..."
    echo ""

    # Parse arguments
    local provider=""
    local project_type=""
    local region=""
    local environment="dev"
    local project_name=$(basename "$(pwd)")

    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            --type=*)
                project_type="${1#*=}"
                shift
                ;;
            --region=*)
                region="${1#*=}"
                shift
                ;;
            --env=*)
                environment="${1#*=}"
                shift
                ;;
            *)
                if [ -z "$project_name" ]; then
                    project_name="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate
    if [ -z "$provider" ]; then
        error "Provider requerido: --provider=aws|gcp"
        return 1
    fi

    if [ -z "$project_type" ]; then
        error "Tipo de proyecto requerido: --type=nextjs|laravel"
        return 1
    fi

    # Check prerequisites
    check_terraform

    case "$provider" in
        aws)
            check_aws_cli
            cloud_init_aws "$project_name" "$project_type" "$region" "$environment"
            ;;
        gcp)
            check_gcloud_cli
            cloud_init_gcp "$project_name" "$project_type" "$region" "$environment"
            ;;
        *)
            error "Provider no soportado: $provider"
            error "Usa: aws o gcp"
            return 1
            ;;
    esac
}

cloud_init_aws() {
    local project_name="$1"
    local project_type="$2"
    local region="${3:-us-east-1}"
    local environment="$4"

    info "Inicializando infraestructura AWS..."
    info "  Proyecto: $project_name"
    info "  Tipo: $project_type"
    info "  Región: $region"
    info "  Ambiente: $environment"
    echo ""

    # Create terraform directory
    local tf_project_dir="terraform/aws/$environment"
    mkdir -p "$tf_project_dir"

    # Copy template
    local template_dir="$TF_DIR/aws/${project_type}-ecs"

    if [ ! -d "$template_dir" ]; then
        error "Template no encontrado: $template_dir"
        return 1
    fi

    cp -r "$template_dir"/* "$tf_project_dir/"

    # Generate terraform.tfvars
    cat > "$tf_project_dir/terraform.tfvars" <<EOF
# Auto-generated by APRO
project_name = "$project_name"
environment  = "$environment"
region       = "$region"

# Compute
app_cpu    = 256
app_memory = 512
min_count  = 1
max_count  = 2

# Database
db_instance_class    = "db.t3.micro"
db_allocated_storage = 20
db_engine           = "mysql"
db_engine_version   = "8.0"

# Networking
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["${region}a", "${region}b"]

# Tags
tags = {
  Project     = "$project_name"
  Environment = "$environment"
  ManagedBy   = "APRO"
}
EOF

    log "Terraform configuración creada en: $tf_project_dir"
    echo ""

    # Initialize Terraform
    info "Inicializando Terraform..."
    cd "$tf_project_dir"

    if terraform init; then
        log "Terraform inicializado correctamente"
        echo ""

        info "Siguientes pasos:"
        echo "  1. Revisa la configuración: cd $tf_project_dir"
        echo "  2. Planea los cambios: terraform plan"
        echo "  3. Aplica cambios: apro deploy $environment"
        echo ""
        success "Infraestructura AWS lista para deploy"
    else
        error "Terraform init falló"
        return 1
    fi
}

cloud_init_gcp() {
    local project_name="$1"
    local project_type="$2"
    local region="${3:-us-central1}"
    local environment="$4"

    info "Inicializando infraestructura GCP..."
    info "  Proyecto: $project_name"
    info "  Tipo: $project_type"
    info "  Región: $region"
    echo ""

    warn "GCP init en desarrollo - próximamente"
    # TODO: Implement GCP initialization
}

#===============================================================================
# Cloud Deploy
#===============================================================================

cloud_deploy() {
    local environment="${1:-dev}"
    local provider=""
    local dry_run=false

    # Parse arguments
    shift  # skip environment arg
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    info "Desplegando a $environment..."
    echo ""

    # Auto-detect provider if not specified
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws/$environment" ]; then
            provider="aws"
        elif [ -d "terraform/gcp/$environment" ]; then
            provider="gcp"
        else
            error "No se encontró configuración de Terraform"
            info "Ejecuta primero: apro init --provider=aws|gcp --type=nextjs|laravel"
            return 1
        fi
    fi

    info "Provider: $provider"
    echo ""

    case "$provider" in
        aws)
            check_terraform
            check_aws_cli
            cloud_deploy_aws "$environment" "$dry_run"
            ;;
        gcp)
            check_terraform
            check_gcloud_cli
            cloud_deploy_gcp "$environment" "$dry_run"
            ;;
        *)
            error "Provider no soportado: $provider"
            return 1
            ;;
    esac
}

cloud_deploy_aws() {
    local environment="$1"
    local dry_run="$2"
    local tf_dir="terraform/aws/$environment"

    if [ ! -d "$tf_dir" ]; then
        error "Directorio de Terraform no encontrado: $tf_dir"
        info "Ejecuta primero: apro init --provider=aws --type=nextjs"
        return 1
    fi

    cd "$tf_dir"

    # Terraform plan
    info "Generando plan de deployment..."
    echo ""

    if ! terraform plan -out=tfplan; then
        error "Terraform plan falló"
        return 1
    fi

    log "Plan generado exitosamente"
    echo ""

    if [ "$dry_run" = true ]; then
        success "Dry-run completado. No se aplicaron cambios."
        info "Para aplicar: apro deploy $environment"
        return 0
    fi

    # Confirm
    warn "Esto creará/modificará recursos en AWS"
    read -p "¿Continuar con el deployment? (y/N): " -r confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "Deployment cancelado"
        return 0
    fi

    # Terraform apply
    info "Aplicando cambios..."
    echo ""

    if terraform apply tfplan; then
        log "Terraform apply completado"
        rm -f tfplan
        echo ""

        # Show outputs
        info "Deployment Summary:"
        echo ""
        terraform output deployment_summary

        echo ""
        success "Deployment completado exitosamente"
        echo ""

        # Next steps
        info "Siguientes pasos:"
        echo ""
        echo "1. Build y push de la imagen Docker:"
        echo ""
        terraform output -json deployment_commands | jq -r '.docker_login'
        echo ""
        terraform output -json deployment_commands | jq -r '.docker_build'
        echo ""
        terraform output -json deployment_commands | jq -r '.docker_push'
        echo ""
        echo "2. Actualizar el servicio ECS:"
        echo ""
        terraform output -json deployment_commands | jq -r '.update_service'
        echo ""
        echo "3. Verificar el deployment:"
        echo ""
        echo "   apro status"
        echo "   apro logs --follow"
        echo ""

        return 0
    else
        error "Terraform apply falló"
        rm -f tfplan
        return 1
    fi
}

cloud_deploy_gcp() {
    local environment="$1"
    local dry_run="$2"

    warn "GCP deployment en desarrollo - próximamente"
    return 1
}

#===============================================================================
# Cloud Destroy
#===============================================================================

cloud_destroy() {
    local environment="${1:-dev}"
    local provider=""
    local force=false

    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Auto-detect provider
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws/$environment" ]; then
            provider="aws"
        elif [ -d "terraform/gcp/$environment" ]; then
            provider="gcp"
        else
            error "No se encontró configuración de Terraform"
            return 1
        fi
    fi

    echo ""
    warn "⚠️⚠️⚠️  PELIGRO  ⚠️⚠️⚠️"
    warn "Vas a DESTRUIR completamente el ambiente: $environment"
    warn "Provider: $provider"
    echo ""
    warn "Esto eliminará:"
    echo "  - Toda la infraestructura (VPC, ECS, ALB, etc.)"
    echo "  - Base de datos (si existe)"
    echo "  - Logs y backups"
    echo ""

    if [ "$force" != true ]; then
        read -p "Escribe '$environment' para confirmar: " -r confirmation

        if [ "$confirmation" != "$environment" ]; then
            info "Cancelado"
            return 0
        fi

        read -p "Escribe 'DESTROY' en mayúsculas para confirmar: " -r confirmation2

        if [ "$confirmation2" != "DESTROY" ]; then
            info "Cancelado"
            return 0
        fi
    fi

    case "$provider" in
        aws)
            cloud_destroy_aws "$environment"
            ;;
        gcp)
            cloud_destroy_gcp "$environment"
            ;;
        *)
            error "Provider no soportado"
            return 1
            ;;
    esac
}

cloud_destroy_aws() {
    local environment="$1"
    local tf_dir="terraform/aws/$environment"

    if [ ! -d "$tf_dir" ]; then
        error "Directorio no encontrado: $tf_dir"
        return 1
    fi

    cd "$tf_dir"

    info "Destruyendo infraestructura AWS..."
    echo ""

    if terraform destroy -auto-approve; then
        success "Infraestructura destruida exitosamente"
        return 0
    else
        error "Terraform destroy falló"
        return 1
    fi
}

cloud_destroy_gcp() {
    warn "GCP destroy en desarrollo"
    return 1
}

#===============================================================================
# Cloud Status
#===============================================================================

cloud_status() {
    local provider=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    info "Estado de infraestructura..."
    echo ""

    # Auto-detect provider
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws" ]; then
            provider="aws"
        elif [ -d "terraform/gcp" ]; then
            provider="gcp"
        else
            warn "No se encontró configuración de Terraform"
            return 1
        fi
    fi

    case "$provider" in
        aws)
            check_aws_cli
            cloud_status_aws
            ;;
        gcp)
            check_gcloud_cli
            cloud_status_gcp
            ;;
        *)
            error "Provider no soportado"
            return 1
            ;;
    esac
}

cloud_status_aws() {
    local region=$(aws configure get region 2>/dev/null || echo "us-east-1")
    local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)

    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}AWS Infrastructure Status${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BOLD}Account:${NC} $account_id"
    echo -e "${BOLD}Region:${NC} $region"
    echo ""

    # ECS Clusters
    echo -e "${CYAN}${BOLD}ECS Clusters:${NC}"
    local clusters=$(aws ecs list-clusters --region "$region" --output json 2>/dev/null | jq -r '.clusterArns[]' 2>/dev/null)

    if [ -n "$clusters" ]; then
        while IFS= read -r cluster_arn; do
            local cluster_name=$(basename "$cluster_arn")
            local services_count=$(aws ecs list-services --cluster "$cluster_arn" --region "$region" --output json 2>/dev/null | jq -r '.serviceArns | length' 2>/dev/null)
            local tasks=$(aws ecs list-tasks --cluster "$cluster_arn" --region "$region" --output json 2>/dev/null | jq -r '.taskArns | length' 2>/dev/null)

            echo -e "  ${GREEN}✓${NC} $cluster_name"
            echo -e "    Services: $services_count | Running tasks: $tasks"
        done <<< "$clusters"
    else
        echo -e "  ${YELLOW}No clusters found${NC}"
    fi
    echo ""

    # Load Balancers
    echo -e "${CYAN}${BOLD}Application Load Balancers:${NC}"
    local albs=$(aws elbv2 describe-load-balancers --region "$region" --output json 2>/dev/null | jq -r '.LoadBalancers[] | select(.Type=="application") | "\(.LoadBalancerName)|\(.DNSName)|\(.State.Code)"' 2>/dev/null)

    if [ -n "$albs" ]; then
        while IFS='|' read -r name dns state; do
            local state_icon="${GREEN}✓${NC}"
            [ "$state" != "active" ] && state_icon="${YELLOW}⚠${NC}"

            echo -e "  $state_icon $name"
            echo -e "    URL: http://$dns"
            echo -e "    State: $state"
        done <<< "$albs"
    else
        echo -e "  ${YELLOW}No load balancers found${NC}"
    fi
    echo ""

    # RDS Instances
    echo -e "${CYAN}${BOLD}RDS Databases:${NC}"
    local dbs=$(aws rds describe-db-instances --region "$region" --output json 2>/dev/null | jq -r '.DBInstances[] | "\(.DBInstanceIdentifier)|\(.DBInstanceStatus)|\(.Engine)|\(.DBInstanceClass)"' 2>/dev/null)

    if [ -n "$dbs" ]; then
        while IFS='|' read -r name status engine instance_class; do
            local status_icon="${GREEN}✓${NC}"
            [ "$status" != "available" ] && status_icon="${YELLOW}⚠${NC}"

            echo -e "  $status_icon $name"
            echo -e "    Engine: $engine | Class: $instance_class"
            echo -e "    Status: $status"
        done <<< "$dbs"
    else
        echo -e "  ${YELLOW}No databases found${NC}"
    fi
    echo ""

    # ECR Repositories
    echo -e "${CYAN}${BOLD}ECR Repositories:${NC}"
    local repos=$(aws ecr describe-repositories --region "$region" --output json 2>/dev/null | jq -r '.repositories[] | "\(.repositoryName)|\(.repositoryUri)"' 2>/dev/null)

    if [ -n "$repos" ]; then
        while IFS='|' read -r name uri; do
            local image_count=$(aws ecr list-images --repository-name "$name" --region "$region" --output json 2>/dev/null | jq -r '.imageIds | length' 2>/dev/null)
            echo -e "  ${GREEN}✓${NC} $name"
            echo -e "    URI: $uri"
            echo -e "    Images: $image_count"
        done <<< "$repos"
    else
        echo -e "  ${YELLOW}No repositories found${NC}"
    fi
    echo ""

    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════${NC}"
}

cloud_status_gcp() {
    warn "GCP status en desarrollo"
    return 1
}

#===============================================================================
# Cloud Logs
#===============================================================================

cloud_logs() {
    local service=""
    local follow=false
    local tail=100
    local provider=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --follow)
                follow=true
                shift
                ;;
            --tail=*)
                tail="${1#*=}"
                shift
                ;;
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            *)
                if [ -z "$service" ]; then
                    service="$1"
                fi
                shift
                ;;
        esac
    done

    # Auto-detect provider
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws" ]; then
            provider="aws"
        elif [ -d "terraform/gcp" ]; then
            provider="gcp"
        else
            error "No se encontró configuración de Terraform"
            return 1
        fi
    fi

    case "$provider" in
        aws)
            check_aws_cli
            cloud_logs_aws "$service" "$follow" "$tail"
            ;;
        gcp)
            check_gcloud_cli
            cloud_logs_gcp "$service" "$follow" "$tail"
            ;;
        *)
            error "Provider no soportado"
            return 1
            ;;
    esac
}

cloud_logs_aws() {
    local service="$1"
    local follow="$2"
    local tail="$3"
    local region=$(aws configure get region 2>/dev/null || echo "us-east-1")

    info "Obteniendo logs de AWS CloudWatch..."
    echo ""

    # Find log groups
    local log_groups=$(aws logs describe-log-groups --region "$region" --output json 2>/dev/null | jq -r '.logGroups[].logGroupName' 2>/dev/null | grep -E '^/ecs/' | head -10)

    if [ -z "$log_groups" ]; then
        warn "No se encontraron log groups de ECS"
        return 1
    fi

    # If service not specified, show available log groups
    if [ -z "$service" ]; then
        info "Log groups disponibles:"
        echo ""
        echo "$log_groups" | nl
        echo ""
        info "Uso: apro logs [log-group-name] [--follow] [--tail=100]"
        return 0
    fi

    # Find matching log group
    local log_group=$(echo "$log_groups" | grep -i "$service" | head -1)

    if [ -z "$log_group" ]; then
        # Use first log group if no match
        log_group=$(echo "$log_groups" | head -1)
        warn "Service '$service' no encontrado, usando: $log_group"
    else
        log "Mostrando logs de: $log_group"
    fi
    echo ""

    # Stream logs
    if [ "$follow" = true ]; then
        aws logs tail "$log_group" --region "$region" --follow --format short
    else
        aws logs tail "$log_group" --region "$region" --since 1h --format short | tail -n "$tail"
    fi
}

cloud_logs_gcp() {
    warn "GCP logs en desarrollo"
    return 1
}

#===============================================================================
# Cloud Scale
#===============================================================================

cloud_scale() {
    local environment="${1:-dev}"
    local min=""
    local max=""
    local desired=""
    local provider=""

    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --min=*)
                min="${1#*=}"
                shift
                ;;
            --max=*)
                max="${1#*=}"
                shift
                ;;
            --desired=*)
                desired="${1#*=}"
                shift
                ;;
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    if [ -z "$min" ] && [ -z "$max" ] && [ -z "$desired" ]; then
        error "Especifica al menos uno: --min, --max, o --desired"
        info "Ejemplo: apro scale prod --min=2 --max=10"
        return 1
    fi

    # Auto-detect provider
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws/$environment" ]; then
            provider="aws"
        elif [ -d "terraform/gcp/$environment" ]; then
            provider="gcp"
        else
            error "No se encontró configuración de Terraform"
            return 1
        fi
    fi

    info "Escalando ambiente: $environment"
    echo ""

    case "$provider" in
        aws)
            check_aws_cli
            cloud_scale_aws "$environment" "$min" "$max" "$desired"
            ;;
        gcp)
            check_gcloud_cli
            cloud_scale_gcp "$environment" "$min" "$max" "$desired"
            ;;
        *)
            error "Provider no soportado"
            return 1
            ;;
    esac
}

cloud_scale_aws() {
    local environment="$1"
    local min="$2"
    local max="$3"
    local desired="$4"
    local region=$(aws configure get region 2>/dev/null || echo "us-east-1")

    # Find ECS cluster and service
    local cluster_name=$(aws ecs list-clusters --region "$region" --output json 2>/dev/null | jq -r '.clusterArns[]' | grep -i "$environment" | head -1 | xargs basename)

    if [ -z "$cluster_name" ]; then
        error "No se encontró cluster ECS para ambiente: $environment"
        return 1
    fi

    local service_name=$(aws ecs list-services --cluster "$cluster_name" --region "$region" --output json 2>/dev/null | jq -r '.serviceArns[]' | head -1 | xargs basename)

    if [ -z "$service_name" ]; then
        error "No se encontró servicio ECS en cluster: $cluster_name"
        return 1
    fi

    info "Cluster: $cluster_name"
    info "Service: $service_name"
    echo ""

    # Update desired count if specified
    if [ -n "$desired" ]; then
        info "Actualizando desired count a: $desired"
        if aws ecs update-service \
            --cluster "$cluster_name" \
            --service "$service_name" \
            --desired-count "$desired" \
            --region "$region" &>/dev/null; then
            log "Desired count actualizado a: $desired"
        else
            error "Failed to update desired count"
            return 1
        fi
    fi

    # Update auto-scaling if min/max specified
    if [ -n "$min" ] || [ -n "$max" ]; then
        local resource_id="service/${cluster_name}/${service_name}"

        info "Actualizando auto-scaling..."

        # Get current min/max if not specified
        local current_min="$min"
        local current_max="$max"

        if [ -z "$current_min" ] || [ -z "$current_max" ]; then
            local scaling_info=$(aws application-autoscaling describe-scalable-targets \
                --service-namespace ecs \
                --resource-ids "$resource_id" \
                --scalable-dimension ecs:service:DesiredCount \
                --region "$region" --output json 2>/dev/null | jq -r '.ScalableTargets[0]')

            [ -z "$current_min" ] && current_min=$(echo "$scaling_info" | jq -r '.MinCapacity')
            [ -z "$current_max" ] && current_max=$(echo "$scaling_info" | jq -r '.MaxCapacity')
        fi

        if aws application-autoscaling register-scalable-target \
            --service-namespace ecs \
            --resource-id "$resource_id" \
            --scalable-dimension ecs:service:DesiredCount \
            --min-capacity "$current_min" \
            --max-capacity "$current_max" \
            --region "$region" &>/dev/null; then
            log "Auto-scaling actualizado: min=$current_min, max=$current_max"
        else
            error "Failed to update auto-scaling"
            return 1
        fi
    fi

    echo ""
    success "Scaling completado exitosamente"
    echo ""

    # Show current status
    info "Estado actual:"
    aws ecs describe-services \
        --cluster "$cluster_name" \
        --services "$service_name" \
        --region "$region" \
        --output json | jq -r '.services[0] | "  Running: \(.runningCount)\n  Desired: \(.desiredCount)\n  Pending: \(.pendingCount)"'
}

cloud_scale_gcp() {
    warn "GCP scaling en desarrollo"
    return 1
}

#===============================================================================
# Cloud Migrate
#===============================================================================

cloud_migrate() {
    info "Migrando entre cloud providers..."

    # TODO: Implement migration
    warn "Migrate en desarrollo"
}

#===============================================================================
# Cloud Rollback
#===============================================================================

cloud_rollback() {
    local version="${1:-previous}"
    local environment="${2:-dev}"
    local provider=""

    # Parse arguments
    shift 2
    while [[ $# -gt 0 ]]; do
        case $1 in
            --provider=*)
                provider="${1#*=}"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Auto-detect provider
    if [ -z "$provider" ]; then
        if [ -d "terraform/aws/$environment" ]; then
            provider="aws"
        elif [ -d "terraform/gcp/$environment" ]; then
            provider="gcp"
        else
            error "No se encontró configuración de Terraform"
            return 1
        fi
    fi

    info "Rollback a versión: $version"
    info "Ambiente: $environment"
    echo ""

    case "$provider" in
        aws)
            check_aws_cli
            cloud_rollback_aws "$version" "$environment"
            ;;
        gcp)
            check_gcloud_cli
            cloud_rollback_gcp "$version" "$environment"
            ;;
        *)
            error "Provider no soportado"
            return 1
            ;;
    esac
}

cloud_rollback_aws() {
    local version="$1"
    local environment="$2"
    local region=$(aws configure get region 2>/dev/null || echo "us-east-1")

    # Find ECS cluster and service
    local cluster_name=$(aws ecs list-clusters --region "$region" --output json 2>/dev/null | jq -r '.clusterArns[]' | grep -i "$environment" | head -1 | xargs basename)

    if [ -z "$cluster_name" ]; then
        error "No se encontró cluster ECS para ambiente: $environment"
        return 1
    fi

    local service_name=$(aws ecs list-services --cluster "$cluster_name" --region "$region" --output json 2>/dev/null | jq -r '.serviceArns[]' | head -1 | xargs basename)

    if [ -z "$service_name" ]; then
        error "No se encontró servicio ECS en cluster: $cluster_name"
        return 1
    fi

    info "Cluster: $cluster_name"
    info "Service: $service_name"
    echo ""

    # Get current task definition
    local current_task_def=$(aws ecs describe-services \
        --cluster "$cluster_name" \
        --services "$service_name" \
        --region "$region" \
        --output json | jq -r '.services[0].taskDefinition')

    info "Task definition actual: $(basename "$current_task_def")"
    echo ""

    # List recent task definitions
    local task_family=$(aws ecs describe-task-definition \
        --task-definition "$current_task_def" \
        --region "$region" \
        --output json | jq -r '.taskDefinition.family')

    info "Versiones disponibles:"
    echo ""

    local task_defs=$(aws ecs list-task-definitions \
        --family-prefix "$task_family" \
        --sort DESC \
        --max-items 10 \
        --region "$region" \
        --output json | jq -r '.taskDefinitionArns[]')

    echo "$task_defs" | nl | head -5
    echo ""

    # Determine target task definition
    local target_task_def=""

    if [ "$version" = "previous" ]; then
        target_task_def=$(echo "$task_defs" | sed -n '2p')  # Second most recent
    else
        target_task_def=$(echo "$task_defs" | grep ":$version")
    fi

    if [ -z "$target_task_def" ]; then
        error "No se encontró task definition para versión: $version"
        return 1
    fi

    info "Haciendo rollback a: $(basename "$target_task_def")"
    echo ""

    warn "Esto actualizará el servicio a una versión anterior"
    read -p "¿Continuar con el rollback? (y/N): " -r confirm

    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "Rollback cancelado"
        return 0
    fi

    # Update service
    info "Actualizando servicio..."

    if aws ecs update-service \
        --cluster "$cluster_name" \
        --service "$service_name" \
        --task-definition "$target_task_def" \
        --force-new-deployment \
        --region "$region" &>/dev/null; then

        log "Servicio actualizado"
        echo ""

        success "Rollback iniciado exitosamente"
        echo ""

        info "Monitorea el progreso con:"
        echo "  apro logs --follow"
        echo "  apro status"

        return 0
    else
        error "Failed to update service"
        return 1
    fi
}

cloud_rollback_gcp() {
    warn "GCP rollback en desarrollo"
    return 1
}
