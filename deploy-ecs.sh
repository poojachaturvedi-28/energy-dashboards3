#!/bin/bash

# Energy Dashboard - AWS ECS Deployment Script
# This script automates the deployment process to AWS ECS

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"
ECR_REPO_NAME="energy-dashboard"
IMAGE_NAME="energy-dashboard"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECS_CLUSTER_NAME="energy-dashboard-cluster"
ECS_SERVICE_NAME="energy-dashboard-service"
ECS_TASK_DEFINITION="energy-dashboard-task"
CONTAINER_PORT="80"
CONTAINER_NAME="energy-dashboard"

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Energy Dashboard - AWS ECS Deployment${NC}"
echo -e "${YELLOW}========================================${NC}\n"

# Step 1: Get AWS Account ID
if [ -z "$AWS_ACCOUNT_ID" ]; then
    echo -e "${YELLOW}Step 1: Getting AWS Account ID...${NC}"
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo -e "${GREEN}✓ AWS Account ID: $AWS_ACCOUNT_ID${NC}\n"
else
    echo -e "${GREEN}✓ Using AWS Account ID: $AWS_ACCOUNT_ID${NC}\n"
fi

# Step 2: Create ECR Repository
echo -e "${YELLOW}Step 2: Creating ECR Repository...${NC}"
ECR_REPOSITORY_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME"

if aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" --region "$AWS_REGION" &>/dev/null; then
    echo -e "${GREEN}✓ ECR Repository already exists: $ECR_REPOSITORY_URI${NC}\n"
else
    echo -e "${YELLOW}Creating new ECR repository...${NC}"
    aws ecr create-repository \
        --repository-name "$ECR_REPO_NAME" \
        --region "$AWS_REGION" \
        --encryption-configuration encryptionType=AES \
        --image-scanning-configuration scanOnPush=true
    echo -e "${GREEN}✓ ECR Repository created: $ECR_REPOSITORY_URI${NC}\n"
fi

# Step 3: Login to ECR
echo -e "${YELLOW}Step 3: Logging into ECR...${NC}"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
echo -e "${GREEN}✓ Successfully logged into ECR${NC}\n"

# Step 4: Build Docker Image
echo -e "${YELLOW}Step 4: Building Docker Image...${NC}"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" .
echo -e "${GREEN}✓ Docker image built: $IMAGE_NAME:$IMAGE_TAG${NC}\n"

# Step 5: Tag Image for ECR
echo -e "${YELLOW}Step 5: Tagging image for ECR...${NC}"
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$ECR_REPOSITORY_URI:$IMAGE_TAG"
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$ECR_REPOSITORY_URI:latest"
echo -e "${GREEN}✓ Image tagged for ECR${NC}\n"

# Step 6: Push Image to ECR
echo -e "${YELLOW}Step 6: Pushing image to ECR...${NC}"
docker push "$ECR_REPOSITORY_URI:$IMAGE_TAG"
docker push "$ECR_REPOSITORY_URI:latest"
echo -e "${GREEN}✓ Image pushed to ECR${NC}\n"

# Step 7: Get ECR Image URI
IMAGE_URI=$(aws ecr describe-images \
    --repository-name "$ECR_REPO_NAME" \
    --region "$AWS_REGION" \
    --image-ids imageTag=latest \
    --query 'imageDetails[0].imageUri' \
    --output text)

echo -e "${GREEN}✓ Image URI: $IMAGE_URI${NC}\n"

# Step 8: Create ECS Cluster (if not exists)
echo -e "${YELLOW}Step 8: Setting up ECS Cluster...${NC}"
if aws ecs describe-clusters --clusters "$ECS_CLUSTER_NAME" --region "$AWS_REGION" | grep -q "ACTIVE"; then
    echo -e "${GREEN}✓ ECS Cluster already exists: $ECS_CLUSTER_NAME${NC}\n"
else
    echo -e "${YELLOW}Creating new ECS cluster...${NC}"
    aws ecs create-cluster \
        --cluster-name "$ECS_CLUSTER_NAME" \
        --region "$AWS_REGION" \
        --settings name=containerInsights,value=enabled
    echo -e "${GREEN}✓ ECS Cluster created: $ECS_CLUSTER_NAME${NC}\n"
fi

# Step 9: Create IAM Role for ECS Task Execution (if not exists)
echo -e "${YELLOW}Step 9: Setting up IAM Role...${NC}"
ROLE_NAME="ecsTaskExecutionRole"

if aws iam get-role --role-name "$ROLE_NAME" &>/dev/null; then
    echo -e "${GREEN}✓ IAM Role already exists: $ROLE_NAME${NC}\n"
else
    echo -e "${YELLOW}Creating IAM role...${NC}"
    
    # Create trust policy
    cat > /tmp/trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document file:///tmp/trust-policy.json
    
    # Attach execution policy
    aws iam attach-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
    
    echo -e "${GREEN}✓ IAM Role created: $ROLE_NAME${NC}\n"
fi

# Get IAM Role ARN
TASK_EXECUTION_ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

# Step 10: Register ECS Task Definition
echo -e "${YELLOW}Step 10: Registering ECS Task Definition...${NC}"

cat > /tmp/task-definition.json << EOF
{
  "family": "$ECS_TASK_DEFINITION",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "$TASK_EXECUTION_ROLE_ARN",
  "containerDefinitions": [
    {
      "name": "$CONTAINER_NAME",
      "image": "$IMAGE_URI",
      "portMappings": [
        {
          "containerPort": $CONTAINER_PORT,
          "hostPort": $CONTAINER_PORT,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/energy-dashboard",
          "awslogs-region": "$AWS_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "wget --quiet --tries=1 --spider http://localhost/health || exit 1"],
        "interval": 30,
        "timeout": 3,
        "retries": 3,
        "startPeriod": 5
      }
    }
  ]
}
EOF

aws ecs register-task-definition \
    --cli-input-json file:///tmp/task-definition.json \
    --region "$AWS_REGION"

echo -e "${GREEN}✓ Task definition registered: $ECS_TASK_DEFINITION${NC}\n"

# Step 11: Create CloudWatch Log Group
echo -e "${YELLOW}Step 11: Creating CloudWatch Log Group...${NC}"
aws logs create-log-group \
    --log-group-name /ecs/energy-dashboard \
    --region "$AWS_REGION" 2>/dev/null || true
echo -e "${GREEN}✓ Log group configured${NC}\n"

echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Deployment Preparation Complete!${NC}"
echo -e "${YELLOW}========================================${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo -e "1. Create VPC and Subnets (or use default VPC)"
echo -e "2. Create Security Group for port 80/443"
echo -e "3. Deploy ECS Service using CloudFormation or AWS Console:"
echo -e "   ${GREEN}aws ecs create-service \\\\"
echo -e "     --cluster $ECS_CLUSTER_NAME \\\\"
echo -e "     --service-name $ECS_SERVICE_NAME \\\\"
echo -e "     --task-definition $ECS_TASK_DEFINITION \\\\"
echo -e "     --desired-count 1 \\\\"
echo -e "     --launch-type FARGATE \\\\"
echo -e "     --network-configuration \"awsvpcConfiguration={subnets=[SUBNET_ID],securityGroups=[SECURITY_GROUP_ID],assignPublicIp=ENABLED}\" \\\\"
echo -e "     --load-balancers targetGroupArn=TARGET_GROUP_ARN,containerName=$CONTAINER_NAME,containerPort=$CONTAINER_PORT \\\\"
echo -e "     --region $AWS_REGION${NC}"
echo ""
echo -e "${YELLOW}Image URI (for reference):${NC} ${GREEN}$IMAGE_URI${NC}"
echo -e "${YELLOW}Cluster Name:${NC} ${GREEN}$ECS_CLUSTER_NAME${NC}"
echo -e "${YELLOW}Task Definition:${NC} ${GREEN}$ECS_TASK_DEFINITION${NC}\n"

# Cleanup
rm -f /tmp/trust-policy.json /tmp/task-definition.json

echo -e "${GREEN}✓ All done!${NC}\n"
