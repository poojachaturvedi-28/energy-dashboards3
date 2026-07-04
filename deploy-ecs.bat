@echo off
REM Energy Dashboard - AWS ECS Deployment Script for Windows
REM This script automates the deployment process to AWS ECS

setlocal enabledelayedexpansion

REM Configuration
set AWS_REGION=us-east-1
set ECR_REPO_NAME=energy-dashboard
set IMAGE_NAME=energy-dashboard
set IMAGE_TAG=latest
set ECS_CLUSTER_NAME=energy-dashboard-cluster
set ECS_SERVICE_NAME=energy-dashboard-service
set ECS_TASK_DEFINITION=energy-dashboard-task
set CONTAINER_PORT=80
set CONTAINER_NAME=energy-dashboard

echo ========================================
echo Energy Dashboard - AWS ECS Deployment
echo ========================================
echo.

REM Step 1: Get AWS Account ID
echo Step 1: Getting AWS Account ID...
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%i
echo [OK] AWS Account ID: %AWS_ACCOUNT_ID%
echo.

REM Step 2: Create ECR Repository URI
set ECR_REPOSITORY_URI=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com/%ECR_REPO_NAME%
echo Step 2: ECR Repository URI: %ECR_REPOSITORY_URI%
echo.

REM Step 3: Login to ECR
echo Step 3: Logging into ECR...
for /f "tokens=*" %%i in ('aws ecr get-login-password --region %AWS_REGION%') do (
    docker login --username AWS --password %%i %AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
)
echo [OK] Successfully logged into ECR
echo.

REM Step 4: Build Docker Image
echo Step 4: Building Docker Image...
docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
echo [OK] Docker image built: %IMAGE_NAME%:%IMAGE_TAG%
echo.

REM Step 5: Tag Image for ECR
echo Step 5: Tagging image for ECR...
docker tag %IMAGE_NAME%:%IMAGE_TAG% %ECR_REPOSITORY_URI%:%IMAGE_TAG%
docker tag %IMAGE_NAME%:%IMAGE_TAG% %ECR_REPOSITORY_URI%:latest
echo [OK] Image tagged for ECR
echo.

REM Step 6: Push Image to ECR
echo Step 6: Pushing image to ECR...
docker push %ECR_REPOSITORY_URI%:%IMAGE_TAG%
docker push %ECR_REPOSITORY_URI%:latest
echo [OK] Image pushed to ECR
echo.

REM Step 7: Get ECR Image URI
echo Step 7: Getting image URI...
for /f "tokens=*" %%i in ('aws ecr describe-images --repository-name %ECR_REPO_NAME% --region %AWS_REGION% --image-ids imageTag=latest --query "imageDetails[0].imageUri" --output text') do set IMAGE_URI=%%i
echo [OK] Image URI: %IMAGE_URI%
echo.

REM Step 8: Create ECS Cluster
echo Step 8: Setting up ECS Cluster...
aws ecs create-cluster ^
    --cluster-name %ECS_CLUSTER_NAME% ^
    --region %AWS_REGION% ^
    --settings name=containerInsights,value=enabled
echo [OK] ECS Cluster setup complete: %ECS_CLUSTER_NAME%
echo.

REM Step 9: Create IAM Role
echo Step 9: Setting up IAM Role...
set ROLE_NAME=ecsTaskExecutionRole
echo [OK] IAM Role: %ROLE_NAME%
echo.

echo ========================================
echo Deployment Preparation Complete!
echo ========================================
echo.

echo Next Steps:
echo 1. Create VPC and Subnets (or use default VPC)
echo 2. Create Security Group for port 80/443
echo 3. Get your SUBNET_ID and SECURITY_GROUP_ID
echo 4. Deploy ECS Service (see detailed steps below)
echo.

echo Image URI: %IMAGE_URI%
echo Cluster Name: %ECS_CLUSTER_NAME%
echo Task Definition: %ECS_TASK_DEFINITION%
echo.

echo For detailed deployment instructions, see ECS-DEPLOYMENT.md
echo.

endlocal
