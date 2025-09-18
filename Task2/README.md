# Prometheus Monitoring Stack with Docker

A comprehensive guide for deploying a complete monitoring solution using Prometheus and Node Exporter in Docker containers.


## 🌟 Overview

This repository provides step-by-step instructions for creating Docker containers for **Node Exporter** and **Prometheus** using custom Dockerfiles. The setup enables comprehensive system monitoring and metrics collection in a containerized environment.

### Key Components

- **Prometheus**: Time-series database and monitoring system
- **Node Exporter**: Hardware and OS metrics collector
- **Docker Network**: Isolated network for secure service communication
- **Custom Images**: Pre-built images with optimized configurations

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                Docker Host                      │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │         prometheus-node network         │   │
│  │                                         │   │
│  │  ┌─────────────────┐  ┌──────────────┐  │   │
│  │  │  Node Exporter  │  │  Prometheus  │  │   │
│  │  │    :9100        │◄─┤    :9090     │  │   │
│  │  └─────────────────┘  └──────────────┘  │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
         ▲                           ▲
         │                           │
    Port 9100                   Port 9090
     (Metrics)                 (Web UI)
```

## ⚡ Prerequisites

- **Operating System**: Ubuntu/Debian-based Linux distribution
- **Privileges**: Sudo access required
- **Network**: Internet connection for downloading Docker images
- **Ports**: Ensure ports 9090 and 9100 are available
- **VM Configuration**: Port 9090 must be open on your VM for external access



## 🚀 Installation Steps

### 1. Docker Installation

Install Docker CE with all necessary components for container management:

#### Add Docker's Official GPG Key

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

#### Add Docker Repository to APT Sources

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

**Installed Components:**
- `docker-ce`: Docker Community Edition engine
- `docker-ce-cli`: Command-line interface tools
- `containerd.io`: Container runtime environment
- `docker-buildx-plugin`: Advanced build capabilities
- `docker-compose-plugin`: Multi-container orchestration

### 2. Network Setup

Create a dedicated Docker network for the monitoring stack:

```bash
docker network create prometheus-node
```

**Network Benefits:**
- **Service Discovery**: Containers can communicate using container names
- **Isolation**: Separate network segment for monitoring services
- **Security**: Network-level isolation from other containers
- **DNS Resolution**: Automatic hostname resolution between services

### 3. Container Deployment

Deploy the monitoring stack using pre-built Docker images:

#### Pull Custom Docker Images

```bash
docker pull earzakantsyan/node-image:v1.0.1
docker pull earzakantsyan/prometheus-image:v1.0.1
```

#### Deploy Node Exporter Container

```bash
docker run --name=node_exporter_instance -p 9100:9100 --network prometheus-node -d earzakantsyan/node-image:v1.0.1
```

**Important**: The container **must** be named `node_exporter_instance` for Prometheus service discovery to work correctly.

**Container Configuration:**
- `--name=node_exporter_instance`: Critical naming for Prometheus target recognition
- `-p 9100:9100`: Exposes metrics endpoint on port 9100
- `--network prometheus-node`: Connects to monitoring network
- `-d`: Runs in detached mode (background)

#### Deploy Prometheus Container

```bash
docker run --name=prometheus_instance -p 9090:9090 --network prometheus-node -d earzakantsyan/prometheus-image:v1.0.1
```

**Container Configuration:**
- `--name=prometheus_instance`: Friendly name for the Prometheus server
- `-p 9090:9090`: Exposes web UI and API on port 9090
- `--network prometheus-node`: Same network as Node Exporter for communication
- `-d`: Background execution mode

## 🌐 Accessing Services

Once deployment is complete, access your monitoring services:

### Prometheus Web UI
- **URL**: `http://[PUBLIC_IP]:9090`
- **Features**: 
  - Query interface for metrics
  - Target status monitoring
  - Configuration management
  - Alerting rules

### Node Exporter Metrics
- **URL**: `http://[PUBLIC_IP]:9100/metrics`
- **Content**: Raw metrics in Prometheus format
- **Data**: System metrics, hardware statistics, OS information

### Service Health Check

Verify both services are running:

```bash
docker ps
```

Expected output should show both containers in "Up" status.

## ⚙️ Configuration Details

| Service | Container Name | Network | Internal Port | External Port | Image |
|---------|---------------|---------|---------------|---------------|-------|
| Prometheus | prometheus_instance | prometheus-node | 9090 | 9090 | earzakantsyan/prometheus-image:v1.0.1 |
| Node Exporter | node_exporter_instance | prometheus-node | 9100 | 9100 | earzakantsyan/node-image:v1.0.1 |

### Network Configuration

- **Network Name**: `prometheus-node`
- **Driver**: bridge (default)
- **Subnet**: Auto-assigned by Docker
- **DNS**: Container name resolution enabled

## 📊 Monitoring Targets

The Prometheus configuration automatically discovers and monitors:

### Node Exporter Metrics
- **CPU Usage**: Processor utilization and load averages
- **Memory**: RAM usage, swap utilization, buffer/cache
- **Disk I/O**: Read/write operations, disk space usage
- **Network**: Interface statistics, packet counts
- **System Load**: Load averages, process counts
- **Hardware**: Temperature, fan speeds (if available)
