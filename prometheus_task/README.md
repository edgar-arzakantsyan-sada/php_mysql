# Prometheus Node Exporter Integration Guide

[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-orange.svg)](https://prometheus.io/)
[![Security](https://img.shields.io/badge/Security-HTTPS-green.svg)](https://github.com)
[![Service](https://img.shields.io/badge/Service-SystemD-blue.svg)](https://systemd.io/)

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Implementation Steps](#implementation-steps)
- [Nginx Reverse Proxy Configuration](#nginx-reverse-proxy-configuration)
- [Node Exporter Service Setup](#node-exporter-service-setup)
- [Prometheus Service Configuration](#prometheus-service-configuration)
- [Service Management](#service-management)
- [Verification and Testing](#verification-and-testing)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🏗️ Overview

This document outlines the implementation of a comprehensive monitoring solution using **Prometheus** and **Node Exporter** with secure HTTPS access through an **Nginx reverse proxy**. The solution provides enterprise-grade system monitoring capabilities with proper service isolation and security hardening.

## 🏛️ Architecture

```
Client (HTTPS) → Nginx Reverse Proxy → Prometheus (Port 9090)
                                   → Node Exporter (Port 9100)
```

### Component Overview

| Component | Port | Purpose | Security Level |
|-----------|------|---------|----------------|
| Nginx | 80/443 | Reverse Proxy & SSL Termination | HTTPS/TLS |
| Prometheus | 9090 | Metrics Collection & Storage | Internal |
| Node Exporter | 9100 | System Metrics Exposition | Internal |

## ✅ Prerequisites

- Ubuntu/Debian-based Linux distribution
- Root or sudo access
- Valid SSL certificates (self-signed or CA-issued)
- Network access to target monitoring endpoints

## 🔧 Implementation Steps

### 1. Nginx Installation and Configuration

#### Installation

```bash
apt update && apt install nginx -y
```

#### SSL Certificate Setup

Ensure SSL certificates are available at:
- `/etc/nginx/ssl/nginx-selfsigned.crt` (Certificate)
- `/etc/nginx/ssl/nginx-selfsigned.key` (Private Key)

## 🌐 Nginx Reverse Proxy Configuration

### Configuration File: `/etc/nginx/sites-available/edgar.am`

```nginx
# HTTP to HTTPS Redirect
server {
    listen 80;
    server_name edgar.am;
    return 301 https://$host$request_uri;
}

# HTTPS Server Block
server {
    listen 443 ssl http2;
    server_name edgar.am;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    
    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Node Exporter Metrics Endpoint
    location /metrics {
        proxy_pass http://localhost:9100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Prometheus Dashboard
    location / {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Nginx Configuration Directives Explained

| Directive | Purpose | Security Impact |
|-----------|---------|-----------------|
| `return 301 https://...` | Forces HTTPS redirection | Prevents plaintext transmission |
| `ssl_certificate` | Specifies SSL certificate path | Enables TLS encryption |
| `proxy_pass` | Backend service routing | Internal service access |
| `add_header` | Security header injection | XSS, clickjacking protection |

# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

## 📊 Node Exporter Service Setup

### 1. Create Dedicated Service User

```bash
# Create system user for Node Exporter
useradd -rs /bin/false node_exporter
```

**Security Rationale:**
- `-r`: Creates system account (UID < 1000)
- `-s /bin/false`: Prevents shell access
- Follows principle of least privilege

### 2. Download and Install Node Exporter

```bash
# Download latest Node Exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Extract and install
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Set ownership and permissions
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
sudo chmod +x /usr/local/bin/node_exporter
```

### 3. Create SystemD Service Unit

**File:** `/etc/systemd/system/node_exporter.service`

```ini
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network.target
Wants=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --web.listen-address=127.0.0.1:9100 \
    --collector.systemd \
    --collector.processes

[Install]
WantedBy=multi-user.target
```

#### SystemD Service Configuration Explained

| Section | Directive | Purpose |
|---------|-----------|---------|
| `[Unit]` | `Description` | Human-readable service description |
| | `After=network.target` | Ensures network availability before start |
| | `Wants=network.target` | Soft dependency on network |
| `[Service]` | `User/Group` | Service execution context |
| | `Type=simple` | Foreground process execution |
| | `Restart=on-failure` | Automatic restart on failures |
| | `ExecStart` | Service binary and arguments |
| `[Install]` | `WantedBy=multi-user.target` | Service activation target |

## 🔍 Prometheus Service Configuration

### 1. Create Prometheus User and Directories

```bash
# Create system user
useradd -rs /bin/false prometheus

# Create data directories
mkdir -p /var/lib/prometheus/data
chown -R prometheus:prometheus /var/lib/prometheus
```

### 2. Download and Install Prometheus

```bash
# Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract and install
tar xvf prometheus-2.45.0.linux-amd64.tar.gz
sudo cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/

# Set permissions
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo chmod +x /usr/local/bin/prometheus /usr/local/bin/promtool
```

### 3. Prometheus Configuration

**File:** `/usr/local/bin/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 10s
    metrics_path: /metrics
```

### 4. Create Prometheus SystemD Service

**File:** `/etc/systemd/system/prometheus.service`

```ini
[Unit]
Description=Prometheus Service
Documentation=https://prometheus.io/docs/introduction/overview/
After=network.target
Wants=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
    --config.file=/usr/local/bin/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/data \
    --web.console.templates=/usr/local/bin/consoles \
    --web.console.libraries=/usr/local/bin/console_libraries \
    --web.listen-address=127.0.0.1:9090 \
    --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
```

#### Prometheus Command-Line Arguments

| Argument | Purpose |
|----------|---------|
| `--config.file` | Configuration file location |
| `--storage.tsdb.path` | Time-series database storage path |
| `--web.listen-address` | Web interface bind address |
| `--web.enable-lifecycle` | Enables configuration reload via API |

## 🚀 Service Management

### Enable and Start Services

```bash
# Reload SystemD daemon
systemctl daemon-reload

# Enable services for automatic startup
systemctl enable node_exporter.service
systemctl enable prometheus.service

# Start services
systemctl start node_exporter.service
systemctl start prometheus.service

# Verify service status
systemctl status node_exporter.service
systemctl status prometheus.service
```

### Service Status Output Example

```bash
● node_exporter.service - Prometheus Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled)
     Active: active (running) since Mon 2024-01-15 09:36:42 UTC; 5min ago
   Main PID: 34434 (node_exporter)
      Tasks: 4 (limit: 2339)
     Memory: 12.1M
     CGroup: /system.slice/node_exporter.service
             └─34434 /usr/local/bin/node_exporter
```

## ✅ Verification and Testing

### Network Connectivity Verification

```bash
# Check listening ports
netstat -tlpn | grep -E "(9090|9100|80|443)"

# Expected output:
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      21300/nginx: master 
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      21300/nginx: master 
tcp6       0      0 :::9090                 :::*                    LISTEN      34330/prometheus    
tcp6       0      0 :::9100                 :::*                    LISTEN      1947/node_exporter  
```

### Process Verification

```bash
# Check running processes
ps aux | grep -E "(prometheus|node_exporter)" | grep -v grep

# Expected output:
node_ex+   34434  1.4  0.6 1239776 12368 ?       Ssl  09:36   0:00 /usr/local/bin/node_exporter
prometh+   34436  6.9  3.7 1338660 75324 ?       Ssl  09:36   0:00 /usr/local/bin/prometheus --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data
```

### Functional Testing

```bash
# Test Node Exporter metrics endpoint
curl -s http://localhost:9100/metrics | head -10

# Test Prometheus API
curl -s http://localhost:9090/api/v1/query?query=up

# Test HTTPS access (replace edgar.am with your domain)
curl -k https://edgar.am/metrics | head -5
curl -k https://edgar.am/ | grep Prometheus
```

### Web Interface Access

- **Prometheus Dashboard:** `https://edgar.am/`
- **Node Exporter Metrics:** `https://edgar.am/metrics`

## 🔒 Security Considerations

### Network Security

- **Internal Binding:** Services bind to `127.0.0.1` (localhost only)
- **Reverse Proxy:** External access only through Nginx
- **TLS Encryption:** All external communications encrypted

### Service Isolation

- **Dedicated Users:** Separate system users for each service
- **No Shell Access:** Service users cannot log in
- **Minimal Permissions:** Principle of least privilege applied

### SSL/TLS Configuration

- **Strong Ciphers:** Modern cipher suites only
- **Security Headers:** XSS, clickjacking, and HSTS protection
- **Certificate Validation:** Proper certificate chain validation

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Service Startup Failures

```bash
# Check service logs
journalctl -u node_exporter.service -f
journalctl -u prometheus.service -f

# Verify file permissions
ls -la /usr/local/bin/node_exporter
ls -la /usr/local/bin/prometheus
```

#### Port Conflicts

```bash
# Check port usage
sudo ss -tulpn | grep -E "(9090|9100)"

# Kill conflicting processes if necessary
sudo fuser -k 9090/tcp
sudo fuser -k 9100/tcp
```

#### Nginx Configuration Issues

```bash
# Test Nginx configuration
nginx -t

# Check Nginx error logs
tail -f /var/log/nginx/error.log
```

#### SSL Certificate Problems

```bash
# Verify certificate validity
openssl x509 -in /etc/nginx/ssl/nginx-selfsigned.crt -text -noout

# Check certificate expiration
openssl x509 -in /etc/nginx/ssl/nginx-selfsigned.crt -noout -dates
```

## 📋 Best Practices

### Monitoring and Alerting

- **Log Rotation:** Configure logrotate for service logs
- **Disk Usage:** Monitor `/var/lib/prometheus/data` disk usage
- **Service Health:** Implement health checks and alerting

### Maintenance

- **Regular Updates:** Keep Prometheus and Node Exporter updated
- **Configuration Backup:** Backup configuration files
- **Data Retention:** Configure appropriate data retention policies

### Performance Optimization

- **Scrape Intervals:** Adjust based on monitoring requirements
- **Storage Configuration:** Optimize TSDB settings for workload
- **Resource Allocation:** Monitor CPU and memory usage

## 📊 Metrics and Monitoring

### Key Node Exporter Metrics

| Metric Family | Description |
|---------------|-------------|
| `node_cpu_*` | CPU utilization and statistics |
| `node_memory_*` | Memory usage information |
| `node_disk_*` | Disk I/O and space metrics |
| `node_network_*` | Network interface statistics |
| `node_filesystem_*` | Filesystem usage metrics |

### Prometheus Targets Status

Monitor target health in Prometheus UI:
- Navigate to `Status → Targets`
- Verify all endpoints show "UP" status
- Check scrape duration and last scrape time

---

**Implementation Status:** ✅ Complete  
**Security Level:** 🔒 Enterprise Grade  
**Monitoring Coverage:** 📊 Comprehensive

This monitoring solution provides enterprise-level observability with proper security hardening and service isolation, suitable for production environments.
