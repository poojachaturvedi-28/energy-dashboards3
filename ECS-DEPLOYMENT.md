# AWS ECS Deployment Guide

## Overview

This guide covers deploying the Energy Dashboard to AWS ECS (Elastic Container Service) with:
- Fargate (serverless containers)
- Application Load Balancer (ALB)
- Auto-scaling
- CloudWatch logs
- CloudFormation for infrastructure

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Docker** installed locally
4. **ECR Repository** created in your AWS account
5. Access to create:
   - ECS resources
   - VPC/Subnets/Security Groups
   - IAM roles
   - Load Balancers
   - CloudWatch logs

## Step-by-Step Deployment

### Step 1: Configure AWS Credentials

```bash
aws configure

# Enter:
# AWS Access Key ID: [your-access-key]
# AWS Secret Access Key: [your-secret-key]
# Default region: us-east-1
# Default output format: json
```

### Step 2: Create ECR Repository

```bash
# Set variables
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO_NAME="energy-dashboard"

# Create repository
aws ecr create-repository \
    --repository-name $ECR_REPO_NAME \
    --region $AWS_REGION \
    --encryption-configuration encryptionType=AES \
    --image-scanning-configuration scanOnPush=true

echo "ECR Repository: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"
```

### Step 3: Build and Push Docker Image

```bash
# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build image
docker build -t energy-dashboard:latest .

# Tag for ECR
docker tag energy-dashboard:latest \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/energy-dashboard:latest

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/energy-dashboard:latest
```

### Step 4: Deploy with CloudFormation

#### Option A: Using AWS Console

1. Go to [CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Click "Create Stack"
3. Choose "Upload a template file"
4. Upload `ecs-cloudformation.yaml`
5. Fill in parameters:
   - **ECRImageUri**: `<account-id>.dkr.ecr.us-east-1.amazonaws.com/energy-dashboard:latest`
   - **Environment**: `production`
   - **DesiredCount**: `1`
   - **TaskCpu**: `256`
   - **TaskMemory**: `512`
6. Click "Create Stack"
7. Wait for stack creation to complete (~5-10 minutes)

#### Option B: Using AWS CLI

```bash
# Set ECR image URI
ECR_IMAGE_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/energy-dashboard:latest"
STACK_NAME="energy-dashboard-prod"

# Deploy CloudFormation stack
aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://ecs-cloudformation.yaml \
    --parameters \
        ParameterKey=ECRImageUri,ParameterValue=$ECR_IMAGE_URI \
        ParameterKey=Environment,ParameterValue=production \
        ParameterKey=DesiredCount,ParameterValue=1 \
        ParameterKey=TaskCpu,ParameterValue=256 \
        ParameterKey=TaskMemory,ParameterValue=512 \
    --region $AWS_REGION

# Wait for stack creation
aws cloudformation wait stack-create-complete \
    --stack-name $STACK_NAME \
    --region $AWS_REGION

echo "Stack creation completed!"
```

### Step 5: Get Load Balancer URL

```bash
# Get ALB DNS name
aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query 'Stacks[0].Outputs[?OutputKey==`LoadBalancerDNS`].OutputValue' \
    --output text

# Your dashboard will be available at:
# http://<load-balancer-dns>
```

### Step 6: Monitor Deployment

```bash
# View stack events
aws cloudformation describe-stack-events \
    --stack-name $STACK_NAME \
    --region $AWS_REGION

# Check ECS service status
aws ecs describe-services \
    --cluster energy-dashboard-cluster-production \
    --services energy-dashboard-service-production \
    --region $AWS_REGION

# View CloudWatch logs
aws logs tail /ecs/energy-dashboard-production --follow
```

## Using Automated Scripts

### Windows Batch Script

```bash
cd d:\energy-dahsboard
deploy-ecs.bat
```

Prompts you through the entire deployment process.

### Linux/Mac Bash Script

```bash
cd d:\energy-dahsboard
chmod +x deploy-ecs.sh
./deploy-ecs.sh
```

## CloudFormation Resources Created

| Resource | Type | Purpose |
|----------|------|---------|
| VPC | AWS::EC2::VPC | Virtual network |
| Subnets | AWS::EC2::Subnet | 2 public subnets across AZs |
| Internet Gateway | AWS::EC2::InternetGateway | Internet access |
| Route Tables | AWS::EC2::RouteTable | Network routing |
| Security Groups | AWS::EC2::SecurityGroup | Firewall rules |
| Load Balancer | AWS::ElasticLoadBalancingV2::LoadBalancer | ALB with health checks |
| Target Group | AWS::ElasticLoadBalancingV2::TargetGroup | Route to ECS tasks |
| ECS Cluster | AWS::ECS::Cluster | Container orchestration |
| Task Definition | AWS::ECS::TaskDefinition | Container configuration |
| ECS Service | AWS::ECS::Service | Running tasks |
| Auto Scaling | AWS::ApplicationAutoScaling::* | CPU-based scaling |
| IAM Roles | AWS::IAM::Role | Permissions |
| CloudWatch Logs | AWS::Logs::LogGroup | Logging |

## Updating the Deployment

### Update Docker Image

```bash
# 1. Make changes to code
# 2. Rebuild and push new image
docker build -t energy-dashboard:v1.1 .
docker tag energy-dashboard:v1.1 \
    $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/energy-dashboard:v1.1
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/energy-dashboard:v1.1

# 3. Update CloudFormation stack
aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --use-previous-template \
    --parameters \
        ParameterKey=ECRImageUri,UsePreviousValue=false,ParameterValue=$NEW_ECR_IMAGE_URI \
    --region $AWS_REGION

# 4. Verify update
aws cloudformation wait stack-update-complete \
    --stack-name $STACK_NAME \
    --region $AWS_REGION
```

## Cost Estimation

### Per-Month Costs (US East 1)

| Service | Usage | Cost |
|---------|-------|------|
| ECS Fargate | 256 CPU/512 MB × 730 hrs | $8.95 |
| Application Load Balancer | 1 ALB | $16.20 |
| NAT Gateway | 1 NGW × 730 hrs | $29.00 |
| Data Transfer | 10 GB/month | $0.90 |
| CloudWatch Logs | 1 GB | $0.50 |
| **Total** | | **~$55.55** |

*Note: Prices vary by region. Free tier may apply for first 12 months.*

## Scaling Configuration

Default auto-scaling targets:
- **Min Tasks**: 1
- **Max Tasks**: 4
- **Target CPU Utilization**: 70%

Modify in CloudFormation parameters or via AWS Console.

## Troubleshooting

### Tasks Not Starting

```bash
# Check task logs
aws logs tail /ecs/energy-dashboard-production --follow

# Check task details
aws ecs list-tasks --cluster energy-dashboard-cluster-production
aws ecs describe-tasks \
    --cluster energy-dashboard-cluster-production \
    --tasks <task-arn>
```

### ALB Health Checks Failing

```bash
# Check target group health
aws elbv2 describe-target-health \
    --target-group-arn <target-group-arn>

# Verify security groups allow traffic
aws ec2 describe-security-groups \
    --group-ids <security-group-id>
```

### High CPU/Memory Usage

1. Increase task resources in CloudFormation
2. Adjust auto-scaling thresholds
3. Optimize application code

## Cleanup

### Delete CloudFormation Stack

```bash
aws cloudformation delete-stack \
    --stack-name $STACK_NAME \
    --region $AWS_REGION
```

### Delete ECR Repository

```bash
aws ecr delete-repository \
    --repository-name energy-dashboard \
    --region $AWS_REGION \
    --force
```

## Security Best Practices

✅ **Enable:**
- CloudWatch monitoring
- ECR image scanning
- VPC security groups
- IAM least privilege
- ECS Container Insights
- ALB access logs

❌ **Avoid:**
- Public security groups
- Root database passwords
- Storing secrets in images
- Running containers as root

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Fargate Pricing](https://aws.amazon.com/fargate/pricing/)
- [CloudFormation Reference](https://docs.aws.amazon.com/cloudformation/)
- [ALB Documentation](https://docs.aws.amazon.com/elasticloadbalancing/)

## Support

For issues or questions:
1. Check CloudWatch Logs
2. Review CloudFormation Events
3. Check AWS ECS Console
4. Review security group rules
5. Verify IAM permissions

---

**Happy deploying!** 🚀
