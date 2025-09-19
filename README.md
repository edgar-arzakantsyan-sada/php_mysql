# Docker Monitoring Stack Setup

A containerized monitoring solution using Docker to deploy Grafana, Prometheus, Node Exporter, and Nginx reverse proxy with secure HTTPS configuration.



## Overview

This setup provides a complete containerized monitoring stack with the following components:

- **Node Exporter**: System metrics collection (Port 9100)
- **Prometheus**: Metrics storage and querying (Port 9090)
- **Grafana**: Data visualization and dashboarding (Port 3000)
- **Nginx**: Reverse proxy with SSL termination (Ports 80/443)

All services run in isolated Docker containers connected through a custom Docker network for secure inter-service communication.

## Architecture

```
External Traffic (HTTPS) → Nginx Container → Internal Docker Network
                                                      ↓
                                          [Node Exporter:9100]
                                          [Prometheus:9090]
                                          [Grafana:3000]
```

## Prerequisites

### System Requirements
- Ubuntu Linux system with sudo privileges
- Internet connection for downloading Docker and images
- Sufficient disk space for containers and volumes

### Required Files
Ensure the following files are present in their respective directories:
- `node_exporter/Dockerfile`
- `prometheus/Dockerfile` and `prometheus/prometheus.yml`
- `grafana/Dockerfile` and `grafana/datasources.yaml`
- `nginx/edgar.conf`, `nginx/nginx-selfsigned.crt`, `nginx/nginx-selfsigned.key`

## Installation Process

### Step 1: Docker Installation

#### Add Docker's Official GPG Key
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

#### Add Docker Repository
```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### Install Docker Components
```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Docker Network Configuration

### Create Custom Network
```bash
docker network create my-network
```

## Docker Volume Configuration

### Create Custom Volume
```bash
docker volume create my-vol
```

**Purpose**: Creates an isolated network for secure inter-container communication without exposing internal ports to the host system.

## Service Deployment

### Node Exporter Container

Navigate to the Node Exporter directory and deploy:

```bash
cd node_exporter
docker build -t node_image .
docker run -d -p 9100:9100 \
  --name node_exporter_instance \
  --network my-network \
  node_image:latest
```

**Configuration Details**:
- **Port Mapping**: `9100:9100` (Host:Container)
- **Network**: Connected to `my-network`
- **Purpose**: System metrics collection and exposition

### Prometheus Container

Navigate to the Prometheus directory and deploy:

```bash
cd ../prometheus
docker build -t prometheus_image .
docker run --name prometheus_instance \
  --network my-network \
  -d -p 9090:9090 \
  --mount type=bind,src=./prometheus.yml,dst=/etc/prometheus/prometheus.yml \
  --mount source=my-vol,target=/var/lib/prometheus/data \
  prometheus_image:latest
```

**Configuration Details**:
- **Port Mapping**: `9090:9090` (Host:Container)
- **Config Mount**: Bind mount for `prometheus.yml` configuration
- **Data Volume**: Named volume `my-vol` for persistent storage
- **Purpose**: Metrics collection, storage, and querying

### Grafana Container

Navigate to the Grafana directory and deploy:

```bash
cd ../grafana
docker build -t grafana_image .
docker run -d -p 3000:3000 \
  --name grafana_instance \
  --network my-network \
  --mount type=bind,src=./datasources.yaml,dst=/usr/local/grafana/conf/provisioning/datasources/datasources.yaml \
  grafana_image:latest
```

**Configuration Details**:
- **Port Mapping**: `3000:3000` (Host:Container)
- **Datasource Mount**: Bind mount for automatic Prometheus datasource configuration
- **Purpose**: Data visualization and dashboard management

### Nginx Reverse Proxy

Pull the official Nginx image and deploy with SSL configuration:

```bash
docker pull nginx
cd ../nginx
docker run --name proxy \
  --network my-network \
  -d -p 80:80 -p 443:443 \
  --mount type=bind,src=./edgar.conf,dst=/etc/nginx/conf.d/edgar.conf \
  --mount type=bind,src=./nginx-selfsigned.crt,dst=/etc/nginx/ssl/nginx-selfsigned.crt \
  --mount type=bind,src=./nginx-selfsigned.key,dst=/etc/nginx/ssl/nginx-selfsigned.key \
  nginx
```

**Configuration Details**:
- **Port Mapping**: `80:80` and `443:443` for HTTP/HTTPS
- **Config Mount**: Custom Nginx configuration for service routing
- **SSL Certificates**: Self-signed certificates for HTTPS termination
- **Purpose**: Reverse proxy with SSL/TLS termination

## Container Management

### Container Status Verification
```bash
# List all running containers
docker ps

# Check container logs
docker logs node_exporter_instance
docker logs prometheus_instance
docker logs grafana_instance
docker logs proxy
```

### Network Inspection
```bash
# Inspect custom network
docker network inspect my-network

# View container network configuration
docker inspect <container_name> | grep -A 20 "NetworkSettings"
```

### Volume Management
```bash
# List Docker volumes
docker volume ls

# Inspect Prometheus data volume
docker volume inspect my-vol
```

## Access Points

After successful deployment, access your services:

- **Grafana Dashboard**: `https://edgar.am/` or `http://localhost:3000`
- **Prometheus Web UI**: `http://localhost:9090`
- **Node Exporter Metrics**: `http://localhost:9100/metrics`
- **Nginx Proxy**: `https://edgar.am` (requires host file entry)

### Host Configuration

Add to `/etc/hosts` for domain-based access:
```bash
127.0.0.1 edgar.am
```

## Container Lifecycle Management

### Starting Stopped Containers
```bash
docker start node_exporter_instance prometheus_instance grafana_instance proxy
```

### Stopping Containers
```bash
docker stop node_exporter_instance prometheus_instance grafana_instance proxy
```

### Removing Containers
```bash
docker rm node_exporter_instance prometheus_instance grafana_instance proxy
```

### Cleanup Commands
```bash
# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove custom network (ensure no containers are using it)
docker network rm my-network
```





