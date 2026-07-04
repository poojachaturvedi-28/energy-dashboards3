# Docker Setup Guide for Energy Dashboard

## Overview

Docker containerizes your energy dashboard application, making it:
- **Portable**: Run anywhere with Docker installed
- **Scalable**: Easy to deploy on cloud platforms
- **Isolated**: No conflicts with system dependencies
- **Production-ready**: Uses Nginx for optimal performance

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop) installed on your system
- Docker Desktop for Windows/Mac or Docker Engine for Linux
- ~500MB disk space for images

## Local Development with Docker

### Option 1: Production Build (Recommended)

```bash
# Navigate to project directory
cd d:\energy-dahsboard

# Build the Docker image
docker build -t energy-dashboard:latest .

# Run the container
docker run -d -p 8080:80 --name energy-dashboard energy-dashboard:latest

# Access dashboard at: http://localhost:8080

# View logs
docker logs energy-dashboard

# Stop container
docker stop energy-dashboard

# Remove container
docker rm energy-dashboard
```

### Option 2: Using Docker Compose

```bash
# Build and start all services
docker-compose up -d

# Access dashboard at: http://localhost:8080

# View logs
docker-compose logs -f energy-dashboard

# Stop all services
docker-compose down

# Remove images too
docker-compose down --rmi all
```

### Option 3: Development Server with Hot Reload

```bash
# Start with dev profile (includes Node.js dev server on port 8000)
docker-compose --profile dev up -d

# Access:
# - Nginx: http://localhost:8080
# - Dev server: http://localhost:8000

# Dev server has file watching for live reload
```

## Docker Image Specs

- **Base Image**: `nginx:alpine` (minimal, ~40MB)
- **Port**: 80 (HTTP)
- **Health Check**: Every 30 seconds
- **Volume Mounts**: Optional for development
- **Compression**: Gzip enabled for all static assets

## Dockerfile Breakdown

```dockerfile
FROM nginx:alpine                    # Lightweight web server
COPY nginx.conf ...                 # Custom Nginx configuration
COPY index.html ./                  # Main HTML file
COPY css/ ./css/                    # Stylesheets
COPY js/ ./js/                      # JavaScript
COPY data/ ./data/                  # Data files
EXPOSE 80                           # Port 80
HEALTHCHECK ...                     # Self-monitoring
CMD ["nginx", "-g", "daemon off;"] # Start server
```

## Docker Compose Services

### energy-dashboard (Production)
- **Image**: Built from Dockerfile
- **Ports**: 8080:80
- **Volumes**: Read-only mounts for live development
- **Restart**: unless-stopped

### dev-server (Optional - Dev Profile)
- **Image**: Node.js Alpine
- **Ports**: 8000:8000
- **Features**: Live reload with http-server
- **Profile**: `dev` (activated with `--profile dev`)

## Nginx Configuration Features

### Security Headers
```nginx
X-Frame-Options: SAMEORIGIN
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Caching Strategy
- **Static assets** (CSS, JS, images): 30 days
- **JSON data**: 1 day
- **HTML**: No cache (must-revalidate)

### Performance
- Gzip compression enabled
- TCP optimizations (tcp_nopush, tcp_nodelay)
- Worker processes: auto-detect

## Common Docker Commands

```bash
# Build image
docker build -t energy-dashboard:latest .

# List images
docker images

# Run container
docker run -d -p 8080:80 --name energy-dashboard energy-dashboard:latest

# View running containers
docker ps

# View all containers
docker ps -a

# Inspect container
docker inspect energy-dashboard

# View logs
docker logs -f energy-dashboard

# Execute command in container
docker exec -it energy-dashboard sh

# Stop container
docker stop energy-dashboard

# Remove container
docker rm energy-dashboard

# Remove image
docker rmi energy-dashboard:latest

# Prune unused resources
docker system prune -a
```

## Deployment Options

### AWS ECS (Elastic Container Service)
```bash
# Tag image for ECR
docker tag energy-dashboard:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/energy-dashboard:latest

# Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/energy-dashboard:latest

# Deploy via CloudFormation or ECS console
```

### Docker Hub
```bash
# Tag image
docker tag energy-dashboard:latest yourusername/energy-dashboard:latest

# Push to Docker Hub
docker push yourusername/energy-dashboard:latest

# Anyone can run:
docker run -d -p 8080:80 yourusername/energy-dashboard:latest
```

### AWS AppRunner
1. Push image to ECR
2. Go to AWS AppRunner console
3. Create service from ECR image
4. Configure port 80
5. Deploy

### Docker Swarm
```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml energy-dashboard

# View services
docker service ls
```

### Kubernetes
```bash
# Convert to Kubernetes deployment
kubectl create deployment energy-dashboard --image=energy-dashboard:latest
kubectl expose deployment energy-dashboard --port=80 --target-port=80 --type=LoadBalancer
```

## Environment Variables (Future Use)

Add to `docker-compose.yml`:
```yaml
environment:
  - NODE_ENV=production
  - COST_PER_KWH=0.12
  - API_ENDPOINT=https://api.example.com
```

## Troubleshooting

### Port Already in Use
```bash
# Find process using port 8080
netstat -ano | findstr :8080

# Kill process (Windows)
taskkill /PID <PID> /F

# Or use different port
docker run -d -p 9000:80 energy-dashboard:latest
```

### Cannot Access Container
```bash
# Check if container is running
docker ps

# View logs for errors
docker logs energy-dashboard

# Check container IP
docker inspect energy-dashboard | grep IPAddress
```

### Build Fails
```bash
# Clear build cache
docker build --no-cache -t energy-dashboard:latest .

# Check Dockerfile syntax
docker build --help

# Remove orphan images
docker image prune -a
```

### Permissions Issue on Linux
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Test
docker ps
```

## Security Best Practices

✅ **Do:**
- Use specific base image versions (`nginx:1.25-alpine`)
- Don't run as root in production
- Scan images for vulnerabilities: `docker scan energy-dashboard:latest`
- Use secrets management for sensitive data
- Keep images small and lightweight

❌ **Don't:**
- Use `latest` tags in production
- Store credentials in Dockerfile
- Run as root user
- Expose unnecessary ports
- Include `.git` or sensitive files

## Multi-Stage Builds (Future)

For apps requiring build steps:
```dockerfile
FROM node:18 as builder
WORKDIR /app
COPY package.json .
RUN npm install && npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Build and Push Docker Image
  run: |
    docker build -t energy-dashboard:${{ github.sha }} .
    docker push <registry>/energy-dashboard:${{ github.sha }}
```

## Performance Tips

1. **Use Alpine images**: ~10x smaller than standard images
2. **Layer caching**: Order Dockerfile commands by change frequency
3. **Minimal layers**: Combine RUN commands
4. **Prune unused images**: `docker image prune -a`
5. **Use .dockerignore**: Reduce build context

## Next Steps

1. Install Docker Desktop
2. Run `docker-compose up -d`
3. Visit http://localhost:8080
4. Share image on Docker Hub or AWS ECR
5. Deploy to cloud platform of choice

Happy containerizing! 🐳
