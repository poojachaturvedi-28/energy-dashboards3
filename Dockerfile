# Multi-stage build for Energy Dashboard

# Stage 1: Build (optional - for future Node.js/build tooling)
FROM node:18-alpine as builder

WORKDIR /app
COPY package.json .
RUN npm install --production

# Stage 2: Production - Nginx server
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy dashboard files
COPY index.html ./
COPY css/ ./css/
COPY js/ ./js/
COPY data/ ./data/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
