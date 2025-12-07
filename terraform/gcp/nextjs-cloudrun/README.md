# Next.js on GCP Cloud Run

Production-ready Terraform configuration for deploying Next.js applications on Google Cloud Run with auto-scaling, high availability, and managed services.

## Architecture

- **Cloud Run**: Fully managed serverless containers
- **Cloud SQL**: Managed PostgreSQL/MySQL database (optional)
- **Artifact Registry**: Private Docker registry
- **VPC Connector**: Private networking (optional)
- **Cloud Load Balancer**: Global load balancing (optional)
- **Secret Manager**: Secure credential storage
- **Cloud Monitoring**: Uptime checks and alerts

## Features

✅ **Serverless** - Pay only for what you use, scale to zero
✅ **Auto-scaling** - Scales from 0 to 1000+ instances automatically
✅ **Global** - Deploy to multiple regions easily
✅ **Zero Configuration** - No infrastructure to manage
✅ **HTTPS by Default** - Automatic TLS certificates
✅ **Monitoring** - Built-in uptime checks and alerts
✅ **Cost Optimized** - Scale to zero in dev, pay per request
✅ **Fast Deployments** - Deploy in seconds, not minutes

## Prerequisites

1. **gcloud CLI** installed and authenticated
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Terraform** >= 1.5.0
   ```bash
   terraform version
   ```

3. **Docker** for building images
   ```bash
   docker --version
   ```

4. **GCP Project** with billing enabled
   ```bash
   gcloud projects create my-project-id
   gcloud config set project my-project-id
   ```

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Minimum required variables:
```hcl
project_name   = "my-nextjs-app"
environment    = "dev"
gcp_project_id = "my-gcp-project-123"
region         = "us-central1"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review Plan

```bash
terraform plan
```

### 4. Deploy Infrastructure

```bash
terraform apply
```

This creates:
- Cloud Run service
- Artifact Registry repository
- Service account with permissions
- Secret Manager secrets
- (Optional) Cloud SQL database
- (Optional) VPC and connector
- (Optional) Load Balancer
- Monitoring and alerts

### 5. Build and Push Docker Image

```bash
# Get deployment commands
terraform output deployment_commands

# Authenticate Docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build image
docker build -t us-central1-docker.pkg.dev/my-project/my-app-dev/app:latest .

# Push image
docker push us-central1-docker.pkg.dev/my-project/my-app-dev/app:latest

# Deploy to Cloud Run
gcloud run services update my-app-dev \
  --region us-central1 \
  --image us-central1-docker.pkg.dev/my-project/my-app-dev/app:latest
```

### 6. Access Your Application

```bash
terraform output service_url
# https://my-app-dev-xxxxx-uc.a.run.app
```

## Configuration

### Environment-Specific Configurations

#### Development
```hcl
environment    = "dev"
app_cpu        = "1"      # 1 vCPU
app_memory     = "512Mi"  # 512 MB
min_instances  = 0        # Scale to zero
max_instances  = 5
cpu_throttling = true     # Save costs
enable_cloud_sql = false
enable_monitoring = false
```

**Estimated Cost**: $0-10/month (only when serving traffic)

#### Staging
```hcl
environment    = "staging"
app_cpu        = "1"
app_memory     = "1Gi"
min_instances  = 1        # Always 1 instance
max_instances  = 10
enable_cloud_sql = true
db_tier        = "db-g1-small"
enable_monitoring = true
```

**Estimated Cost**: $30-80/month

#### Production
```hcl
environment    = "production"
app_cpu        = "2"
app_memory     = "2Gi"
min_instances  = 2        # Always 2 instances
max_instances  = 100
cpu_throttling = false    # Max performance
enable_cloud_sql     = true
db_tier              = "db-custom-2-7680"
db_high_availability = true
enable_load_balancer = true
enable_vpc           = true
enable_monitoring    = true
```

**Estimated Cost**: $150-400/month (base + traffic)

### CPU and Memory Combinations

Cloud Run supports flexible CPU/Memory combinations:

| CPU | Memory Options |
|-----|----------------|
| 1   | 128Mi, 256Mi, 512Mi, 1Gi, 2Gi, 4Gi |
| 2   | 512Mi, 1Gi, 2Gi, 4Gi, 8Gi |
| 4   | 2Gi, 4Gi, 8Gi |
| 8   | 4Gi, 8Gi, 16Gi, 32Gi |

### Auto-Scaling

Cloud Run auto-scales based on:
- **Concurrent requests** per instance (default: 80)
- **CPU utilization** target (default: 60%)
- **Min instances**: Always running (0 = scale to zero)
- **Max instances**: Upper limit (1-1000)

**Scale to Zero** (Dev/Staging):
```hcl
min_instances = 0  # Saves costs when idle
```

**Always Available** (Production):
```hcl
min_instances = 2  # No cold starts
max_instances = 100
```

### Database Configuration

Enable Cloud SQL database:

```hcl
enable_cloud_sql = true

# PostgreSQL (recommended for Next.js)
db_version     = "POSTGRES_15"
db_tier        = "db-f1-micro"      # Development
# db_tier      = "db-custom-2-7680" # Production (2 vCPU, 7.6GB)

# MySQL
# db_version   = "MYSQL_8_0"

db_disk_size            = 10    # GB
db_disk_type            = "PD_SSD"
db_high_availability    = false # true for production
db_backup_enabled       = true
db_point_in_time_enabled = true
```

**Database Tiers**:
- `db-f1-micro`: 0.6GB RAM, shared CPU (~$8/month)
- `db-g1-small`: 1.7GB RAM, shared CPU (~$25/month)
- `db-custom-1-3840`: 1 vCPU, 3.75GB RAM (~$50/month)
- `db-custom-2-7680`: 2 vCPU, 7.5GB RAM (~$100/month)

Connection in Cloud Run is automatic via Unix socket:
```javascript
// Next.js with Prisma
DATABASE_URL="postgresql://user:password@/dbname?host=/cloudsql/project:region:instance"
```

### VPC and Private Networking

Enable VPC for private Cloud SQL access:

```hcl
enable_vpc = true
vpc_cidr           = "10.8.0.0/28"
vpc_connector_cidr = "10.8.1.0/28"
```

**When to use VPC**:
- Private Cloud SQL connections
- VPC Peering with other services
- Cloud VPN/Interconnect
- Firewall rules

**Note**: VPC Connector costs ~$9/month even when idle

### Custom Domain and Load Balancer

Enable Load Balancer for:
- Custom domain (your-domain.com)
- Static IP address
- Cloud CDN
- Cloud Armor (WAF)

```hcl
enable_load_balancer = true
```

Then configure:
1. **DNS**: Point your domain to the static IP
2. **SSL Certificate**: Google-managed SSL cert
3. **Domain Mapping**: Map domain to Cloud Run

```bash
# Get static IP
terraform output load_balancer_ip

# Map domain
gcloud run domain-mappings create \
  --service my-app-prod \
  --domain your-domain.com \
  --region us-central1
```

## Monitoring

### Cloud Monitoring

Automatic uptime checks when `enable_monitoring = true`:
- Health endpoint checks every 60 seconds
- Alerts on downtime
- Query metrics in Cloud Monitoring

View monitoring:
```bash
terraform output monitoring_urls
```

### Available Metrics

**Cloud Run**:
- Request count
- Request latency (p50, p95, p99)
- Instance count
- CPU utilization
- Memory utilization
- Billable time

**Cloud SQL**:
- CPU utilization
- Memory utilization
- Disk utilization
- Connections count
- Queries per second

### Alerts

Configured alerts:
- Service down (uptime check failed)
- Database CPU > 80%
- Database memory > 90%
- Database disk > 85%

Add notification channels:
```hcl
notification_channels = [
  "projects/my-project/notificationChannels/1234567890"
]
```

Create channels:
```bash
# Email
gcloud alpha monitoring channels create \
  --display-name="Team Email" \
  --type=email \
  --channel-labels=email_address=team@example.com

# Slack
gcloud alpha monitoring channels create \
  --display-name="Slack" \
  --type=slack \
  --channel-labels=url=https://hooks.slack.com/...
```

## Health Checks

Cloud Run expects health endpoint at:
```
/api/health
```

Create in Next.js:
```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  });
}
```

Health check configuration:
- **Startup probe**: 10s initial delay, 10s period, 3 failures
- **Liveness probe**: 30s initial delay, 30s period, 3 failures

## Cost Optimization

### Development
```hcl
min_instances  = 0        # Scale to zero ($0 when idle)
cpu_throttling = true     # Reduce CPU when idle
enable_cloud_sql = false  # Use external DB or mock
enable_monitoring = false # Reduce API calls
```

**Cost**: $0-10/month

### Staging
```hcl
min_instances = 1         # 1 always-on instance
enable_cloud_sql = true
db_tier = "db-f1-micro"  # Shared CPU
```

**Cost**: $30-80/month

### Production - Cost Optimized
```hcl
min_instances = 2         # 2 always-on
max_instances = 50        # Reasonable limit
enable_cloud_sql = true
db_tier = "db-custom-1-3840"
```

**Cost**: $100-200/month + traffic

### Production - High Performance
```hcl
min_instances = 10        # No cold starts
max_instances = 100
cpu_throttling = false
db_tier = "db-custom-4-15360"
db_high_availability = true
enable_load_balancer = true
```

**Cost**: $500-1000/month + traffic

## Secrets Management

Secrets are stored in Secret Manager:

```bash
# Create secret
echo -n "my-secret-value" | gcloud secrets create my-secret --data-file=-

# Use in Cloud Run
gcloud run services update my-service \
  --update-secrets=ENV_VAR=my-secret:latest
```

In Terraform:
```hcl
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"
  replication { auto {} }
}

# Reference in Cloud Run container env
env {
  name = "API_KEY"
  value_source {
    secret_key_ref {
      secret  = google_secret_manager_secret.api_key.secret_id
      version = "latest"
    }
  }
}
```

## Deployment Strategies

### Blue/Green Deployments

```bash
# Deploy to new revision with 0% traffic
gcloud run services update my-service \
  --image new-image:v2 \
  --no-traffic \
  --tag blue

# Test the new revision
curl https://blue---my-service-xxx.run.app

# Gradually shift traffic
gcloud run services update-traffic my-service \
  --to-revisions=LATEST=10,blue=90

# Full rollout
gcloud run services update-traffic my-service \
  --to-latest
```

### Canary Deployments

```bash
# Deploy canary with 10% traffic
gcloud run services update my-service \
  --image new-image:canary \
  --tag canary

gcloud run services update-traffic my-service \
  --to-revisions=LATEST=10,stable=90
```

### Rollback

```bash
# List revisions
gcloud run revisions list --service my-service

# Rollback to specific revision
gcloud run services update-traffic my-service \
  --to-revisions=my-service-00005-abc=100
```

## Remote State

For team collaboration, use GCS backend:

1. Create GCS bucket:
   ```bash
   gsutil mb gs://my-terraform-state
   gsutil versioning set on gs://my-terraform-state
   ```

2. Uncomment backend in `main.tf`:
   ```hcl
   backend "gcs" {
     bucket = "my-terraform-state"
     prefix = "apro/my-app/dev"
   }
   ```

3. Re-initialize:
   ```bash
   terraform init -migrate-state
   ```

## Troubleshooting

### Service not starting

Check logs:
```bash
gcloud run services logs read my-service --region us-central1 --limit 50
```

Common issues:
- Port mismatch (app not listening on $PORT)
- Health check failures
- Permission issues
- Database connection failures

### Database connection failures

Verify:
```bash
# Test Cloud SQL connection
gcloud sql connect my-instance --user=postgres

# Check Cloud Run has Cloud SQL client role
gcloud projects get-iam-policy my-project \
  --flatten="bindings[].members" \
  --filter="bindings.role:roles/cloudsql.client"
```

### High costs

Review:
- Min instances (reduce or set to 0)
- CPU throttling (enable for dev/staging)
- Database tier (use smaller tier)
- Request timeout (reduce if possible)
- VPC Connector (disable if not needed)

### Cold starts

Solutions:
- Set `min_instances = 1` or higher
- Enable `startup_cpu_boost = true`
- Reduce image size
- Use distroless base images

## Cleanup

To destroy all infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete:
- Cloud Run service
- Database (including all data)
- Artifact Registry images
- All configurations

## Outputs

After deployment:

```bash
terraform output service_url          # Cloud Run URL
terraform output artifact_registry_url # Docker registry
terraform output deployment_commands   # Deployment commands
terraform output monitoring_urls       # Monitoring dashboards
terraform output deployment_summary    # Complete summary
```

## Next Steps

1. **Configure CI/CD** - GitHub Actions or Cloud Build
2. **Add Custom Domain** - Domain mapping and SSL
3. **Enable Cloud CDN** - Cache static assets globally
4. **Add Cloud Armor** - WAF and DDoS protection
5. **Multi-Region** - Deploy to multiple regions
6. **Monitoring** - Custom dashboards and alerts

## Support

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- APRO Docs: `/home/user/apro/docs/`

---

**APRO** - Advanced Provisioning & Orchestration
Version: 2.0.0-cloud
