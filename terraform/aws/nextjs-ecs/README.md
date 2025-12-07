# Next.js on AWS ECS Fargate

Production-ready Terraform configuration for deploying Next.js applications on AWS ECS Fargate with auto-scaling, high availability, and monitoring.

## Architecture

- **VPC**: Multi-AZ with public and private subnets
- **ALB**: Application Load Balancer for traffic distribution
- **ECS Fargate**: Serverless containers (no EC2 management)
- **ECR**: Private Docker registry
- **RDS**: Optional MySQL/PostgreSQL database
- **Auto-scaling**: Based on CPU and memory metrics
- **CloudWatch**: Centralized logging and monitoring

## Features

✅ **Multi-AZ High Availability** - Deploys across multiple availability zones
✅ **Auto-scaling** - Scales based on CPU (70%) and memory (80%) utilization
✅ **Zero-downtime Deployments** - Rolling updates with health checks
✅ **Circuit Breaker** - Automatic rollback on deployment failures
✅ **Container Insights** - Advanced monitoring and metrics
✅ **Secrets Management** - Integration with AWS Secrets Manager
✅ **CloudWatch Logs** - Centralized log aggregation
✅ **Cost Optimized** - Configurable for dev/staging/production

## Prerequisites

1. **AWS CLI** configured with credentials
   ```bash
   aws configure
   ```

2. **Terraform** >= 1.5.0
   ```bash
   terraform version
   ```

3. **Docker** for building images
   ```bash
   docker --version
   ```

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Minimum required variables:
```hcl
project_name = "my-nextjs-app"
environment  = "dev"
region       = "us-east-1"
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
- VPC with public and private subnets
- Application Load Balancer
- ECS Cluster and Service
- ECR Repository
- Security Groups
- IAM Roles
- CloudWatch Log Groups
- Auto-scaling policies
- (Optional) RDS Database

### 5. Build and Push Docker Image

After infrastructure is created, get the deployment commands:

```bash
terraform output deployment_commands
```

Example output:
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build image
docker build -t 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-nextjs-app/dev:latest .

# Push image
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-nextjs-app/dev:latest

# Update service
aws ecs update-service --cluster my-nextjs-app-dev --service my-nextjs-app-dev --force-new-deployment --region us-east-1
```

### 6. Access Your Application

```bash
terraform output application_url
# http://my-nextjs-app-dev-alb-123456789.us-east-1.elb.amazonaws.com
```

## Configuration

### Environment-Specific Configurations

#### Development
```hcl
environment             = "dev"
app_cpu                 = 256    # 0.25 vCPU
app_memory              = 512    # 512 MB
desired_count           = 1
min_count               = 1
max_count               = 2
single_nat_gateway      = true   # Cost optimization
enable_container_insights = false
enable_rds              = false
```

**Estimated Cost**: ~$40-60/month

#### Staging
```hcl
environment             = "staging"
app_cpu                 = 512    # 0.5 vCPU
app_memory              = 1024   # 1 GB
desired_count           = 2
min_count               = 1
max_count               = 5
single_nat_gateway      = true
enable_container_insights = true
enable_rds              = true
db_multi_az             = false
```

**Estimated Cost**: ~$100-150/month

#### Production
```hcl
environment             = "production"
app_cpu                 = 1024   # 1 vCPU
app_memory              = 2048   # 2 GB
desired_count           = 3
min_count               = 2
max_count               = 20
single_nat_gateway      = false  # NAT redundancy
enable_container_insights = true
enable_rds              = true
db_multi_az             = true   # High availability
db_backup_retention_days = 30
```

**Estimated Cost**: ~$300-500/month (base)

### CPU and Memory Combinations

Valid Fargate CPU/Memory combinations:

| CPU (vCPU) | Memory (MB) Options |
|------------|---------------------|
| 256 (0.25) | 512, 1024, 2048 |
| 512 (0.5)  | 1024, 2048, 3072, 4096 |
| 1024 (1)   | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 (2)   | 4096 to 16384 (1 GB increments) |
| 4096 (4)   | 8192 to 30720 (1 GB increments) |

### Auto-Scaling

Auto-scaling is configured with two metrics:

1. **CPU Target**: 70% average utilization
   - Scale out cooldown: 60 seconds
   - Scale in cooldown: 300 seconds

2. **Memory Target**: 80% average utilization
   - Scale out cooldown: 60 seconds
   - Scale in cooldown: 300 seconds

To adjust thresholds, modify in `main.tf`:
```hcl
resource "aws_appautoscaling_policy" "ecs_cpu" {
  target_tracking_scaling_policy_configuration {
    target_value = 70.0  # Change here
  }
}
```

### Database Configuration

Enable RDS database:

```hcl
enable_rds              = true
db_engine               = "mysql"     # or "postgres"
db_engine_version       = "8.0"       # or "14" for postgres
db_instance_class       = "db.t3.micro"
db_allocated_storage    = 20
db_multi_az             = false       # true for production
db_backup_retention_days = 7
```

Database credentials are stored in AWS Secrets Manager at:
```
{project_name}/{environment}/db-credentials
```

Access in your application:
```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

const secret = await secretsManager.getSecretValue({
  SecretId: 'my-nextjs-app/dev/db-credentials'
}).promise();

const credentials = JSON.parse(secret.SecretString);
// { username, password, host, port, dbname, engine }
```

## Monitoring

### CloudWatch Dashboards

View logs:
```bash
terraform output monitoring_urls
```

Or access directly:
- **ECS Console**: https://console.aws.amazon.com/ecs
- **CloudWatch Logs**: https://console.aws.amazon.com/cloudwatch
- **ALB Console**: https://console.aws.amazon.com/ec2/v2/home#LoadBalancers

### Container Insights

When `enable_container_insights = true`, you get:
- Task-level CPU and memory metrics
- Container-level resource utilization
- Service and cluster performance metrics

### CloudWatch Alarms

Database alarms are created automatically:
- High CPU utilization (>80%)
- Low freeable memory (<500 MB)
- Low storage space (<2 GB)
- High connection count (>80)

## Health Checks

The configuration expects a health check endpoint at:
```
/api/health
```

Create in your Next.js app:
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
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy threshold**: 2 consecutive successes
- **Unhealthy threshold**: 2 consecutive failures
- **Grace period**: 60 seconds

## HTTPS / SSL

To enable HTTPS:

1. Create ACM certificate:
   ```bash
   aws acm request-certificate \
     --domain-name myapp.example.com \
     --validation-method DNS \
     --region us-east-1
   ```

2. Add certificate ARN to `terraform.tfvars`:
   ```hcl
   certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc123..."
   ```

3. Uncomment HTTPS listener in `main.tf` (lines 249-260)

4. (Optional) Redirect HTTP to HTTPS (lines 238-244)

## Remote State

For team collaboration, enable remote state storage:

1. Create S3 bucket and DynamoDB table:
   ```bash
   aws s3 mb s3://my-terraform-state
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

2. Uncomment backend configuration in `main.tf` (lines 17-24)

3. Re-initialize:
   ```bash
   terraform init -migrate-state
   ```

## Cost Optimization

### Development
- Use `single_nat_gateway = true` (~$32/month vs ~$64/month)
- Set `enable_container_insights = false` (saves ~$10/month)
- Use `db.t3.micro` or `db.t4g.micro` for database
- Set `min_count = 1` and `desired_count = 1`
- Use Fargate Spot (modify capacity provider weights)

### Production
- Enable `db_multi_az = true` for high availability
- Use multiple NAT Gateways for redundancy
- Consider Reserved Capacity for predictable workloads
- Enable Container Insights for observability
- Increase backup retention: `db_backup_retention_days = 30`

## Troubleshooting

### Tasks not starting

Check ECS task logs:
```bash
aws logs tail /ecs/my-nextjs-app/dev --follow
```

Common issues:
- Image pull errors (check ECR permissions)
- Health check failures (verify /api/health endpoint)
- Insufficient resources (increase CPU/memory)

### High costs

Review:
- Auto-scaling min/max counts
- NAT Gateway usage (consider single NAT for non-prod)
- Container Insights enabled when not needed
- RDS instance running when not needed

### Database connection failures

Verify:
- Security group allows traffic from ECS tasks
- Database is in same VPC
- Credentials are correct in Secrets Manager
- Network connectivity (check VPC Flow Logs)

## Cleanup

To destroy all infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete:
- All running tasks
- Load balancer
- Database (unless deletion protection is enabled)
- All logs older than retention period

## Outputs

After deployment, useful outputs:

```bash
terraform output application_url      # Application URL
terraform output ecr_repository_url   # ECR repository for Docker images
terraform output ecs_cluster_name     # ECS cluster name
terraform output deployment_commands  # Commands to deploy
terraform output monitoring_urls      # Monitoring dashboards
terraform output deployment_summary   # Complete summary
```

## Next Steps

1. **Configure CI/CD** - Set up GitHub Actions or GitLab CI
2. **Add Custom Domain** - Configure Route53 and ACM certificate
3. **Enable WAF** - Add AWS WAF for security
4. **Add CDN** - CloudFront distribution for static assets
5. **Monitoring** - Set up CloudWatch alarms and dashboards
6. **Backup Strategy** - Configure RDS snapshots and retention

## Support

For issues or questions:
- Check the [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Review AWS [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
- See APRO documentation: `/home/user/apro/docs/`

---

**APRO** - Advanced Provisioning & Orchestration
Version: 2.0.0-cloud
