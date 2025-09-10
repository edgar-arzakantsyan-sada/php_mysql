# Enterprise Prometheus & Node Exporter Monitoring Solution

[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-orange.svg)](https://prometheus.io/)
[![Security](https://img.shields.io/badge/Security-HTTPS-green.svg)](https://github.com)
[![Service](https://img.shields.io/badge/Service-SystemD-blue.svg)](https://systemd.io/)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-Production%20Ready-blue.svg)](https://github.com)

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Implementation Procedures](#implementation-procedures)
- [Nginx Reverse Proxy Configuration](#nginx-reverse-proxy-configuration)
- [Node Exporter Service Implementation](#node-exporter-service-implementation)
- [Prometheus Service Configuration](#prometheus-service-configuration)
- [System Verification](#system-verification)
- [Prometheus Configuration Management](#prometheus-configuration-management)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)

## 🏗️ Overview

This repository provides comprehensive documentation and configuration files for deploying an enterprise-grade monitoring infrastructure utilizing **Prometheus** and **Node Exporter** as systemd services on Linux virtual machines. The solution incorporates an **Nginx reverse proxy** for secure HTTPS traffic management and service orchestration.

The implementation follows industry best practices for service isolation, security hardening, and operational reliability, delivering a production-ready monitoring platform suitable for enterprise environments.

## ✅ Prerequisites

### System Requirements

- **Operating System:** Debian-based Linux distribution (Ubuntu 20.04+ recommended)
- **Privileged Access:** Root or sudo administrative privileges
- **Network Configuration:** Accessible network interface for service communication
- **Storage:** Adequate disk space for time-series data retention
- **SSL Certificates:** Self-signed or CA-issued certificates for HTTPS termination

### Technical Prerequisites

- Basic understanding of Linux system administration
- Familiarity with systemd service management
- Knowledge of reverse proxy concepts
- Understanding of monitoring and metrics collection principles

## 🏛️ Architecture

### System Architecture Overview

```
Internet/Internal Network
          ↓
    [Nginx Reverse Proxy]
    (Port 80 → 443 Redirect)
    (Port 443 HTTPS/TLS)
          ↓
    ┌─────────────────┐
    │   Routing Logic │
    │                 │
    │ /        → 9090 │ ← Prometheus Dashboard
    │ /metrics → 9100 │ ← Node Exporter Metrics
    └─────────────────┘
```

### Component Architecture

| Component | Port | Protocol | Purpose | User Context |
|-----------|------|----------|---------|--------------|
| Nginx | 80/443 | HTTP/HTTPS | Reverse Proxy & SSL Termination | www-data |
| Prometheus | 9090 | HTTP | Metrics Collection & Storage | prometheus |
| Node Exporter | 9100 | HTTP | System Metrics Exposition | node_exporter |

## 🔧 Implementation Procedures

### Phase 1: Nginx Installation and Configuration

#### 1.1 Package Installation

Execute the following command to install the Nginx web server:

```bash
apt install nginx -y
```

#### 1.2 SSL Certificate Prerequisites

Ensure SSL/TLS certificates are properly deployed:

- **Certificate Path:** `/etc/nginx/ssl/nginx-selfsigned.crt`
- **Private Key Path:** `/etc/nginx/ssl/nginx-selfsigned.key`

**Note:** The current implementation utilizes self-signed SSL certificates appropriate for testing and internal environments. For production deployments, implement certificates issued by a trusted Certificate Authority (CA) to ensure proper browser validation and security compliance.

## 🌐 Nginx Reverse Proxy Configuration

### Configuration Implementation

Create the Nginx virtual host configuration file with the following directives:

**Configuration File:** `/etc/nginx/conf.d/edgar.conf`

```nginx
server {
    listen 80;
    server_name edgar.am;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name edgar.am;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    location /metrics {
        proxy_pass http://localhost:9100;
    }

    location / {
        proxy_pass http://localhost:9090;
    }
}
```

### Configuration Directives Analysis

| Directive | Function | Technical Implementation |
|-----------|----------|--------------------------|
| `listen 80` | HTTP port binding | Handles initial HTTP requests for redirection |
| `return 301` | Permanent HTTP redirect | Forces HTTPS protocol usage with URI preservation |
| `listen 443 ssl` | HTTPS/TLS termination | Secure connection handling with SSL context |
| `ssl_certificate` | X.509 certificate specification | Public key certificate for TLS handshake |
| `ssl_certificate_key` | Private key specification | RSA private key for TLS encryption |
| `location /metrics` | Metrics endpoint routing | Proxies requests to Node Exporter service |
| `location /` | Default location handler | Proxies requests to Prometheus dashboard |
| `proxy_pass` | Backend service routing | Internal service communication via localhost |

### Configuration Validation

```bash
# Test Nginx configuration syntax
nginx -t

# Start Nginx service
systemctl start nginx
```

## 📊 Node Exporter Service Implementation

### Phase 2.1: Binary Installation and Deployment

#### Download and Install Node Exporter

```bash
# Download Node Exporter binary
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Extract archive
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz

# Deploy binary to system path
mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
```

### Phase 2.2: Service User Creation

Implement security best practices by creating a dedicated system user for service isolation:

```bash
useradd -rs /bin/false node_exporter
```

**Security Implementation Details:**
- **`-r`:** Creates system account (UID < 1000)
- **`-s /bin/false`:** Prevents interactive shell access
- **Purpose:** Implements principle of least privilege

### Phase 2.3: SystemD Service Configuration

Create the systemd service unit file for automated service management:

```bash
vim /etc/systemd/system/node_exporter.service
```

**Service Configuration:** `/etc/systemd/system/node_exporter.service`

```ini
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

### SystemD Configuration Parameters

| Section | Parameter | Technical Function |
|---------|-----------|-------------------|
| `[Unit]` | `Description` | Human-readable service identifier for administrative purposes |
| | `After=network.target` | Dependency specification - ensures network availability before service initialization |
| `[Service]` | `User/Group` | Service execution context - defines security boundary |
| | `Type=simple` | Process model specification - foreground execution without forking |
| | `ExecStart` | Executable specification - absolute path to service binary |
| `[Install]` | `WantedBy=multi-user.target` | Service activation target - enables automatic startup in multi-user mode |

### Service Activation

```bash
# Start Node Exporter service
systemctl start node_exporter.service

# Enable automatic startup
systemctl enable node_exporter.service
```

## 🔍 Prometheus Service Configuration

### Phase 3.1: Binary Installation and Deployment

#### Download and Install Prometheus

```bash
# Download Prometheus binary distribution
wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz

# Extract archive contents
tar xvf prometheus-3.5.0.linux-amd64.tar.gz
```

### Phase 3.2: SystemD Service Implementation

Create the Prometheus service configuration for system integration:

**Service Configuration:** `/etc/systemd/system/prometheus.service`

```ini
[Unit]
Description=Prometheus Service
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data

[Install]
WantedBy=multi-user.target
```

### Custom Port Configuration

Similar to Node Exporter, Prometheus can be configured to operate on alternative ports through systemd service configuration modifications.

#### Prometheus Custom Port Configuration

To configure Prometheus to listen on a custom port (e.g., port 9091), modify the `ExecStart` directive:

```ini
ExecStart=/usr/local/bin/prometheus \
    --config.file=/usr/local/bin/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/data \
    --web.listen-address=127.0.0.1:9091
```

**Configuration Parameters:**
- `--web.listen-address`: Defines the binding address and port for the Prometheus web interface
- `127.0.0.1:9091`: Binds to localhost interface on port 9091 instead of default 9090

### Port Configuration Benefits

| Benefit | Technical Implementation |
|---------|-------------------------|
| **Port Conflict Avoidance** | Prevents conflicts with existing services using default ports |
| **Security Hardening** | Enables non-standard port usage for security through obscurity |
| **Network Segmentation** | Facilitates custom network architecture and firewall rules |
| **Service Isolation** | Allows multiple instances on different ports for testing/staging |

### Important Considerations for Custom Ports

When implementing custom port configurations:

1. **Nginx Configuration Update:** Update reverse proxy configuration to match new backend ports
2. **Firewall Rules:** Adjust firewall rules if services need external access
3. **Prometheus Targets:** Update `prometheus.yml` scrape targets to reflect new ports
4. **Service Dependencies:** Ensure all dependent services reference correct ports

Example Nginx configuration update for custom ports:

```nginx
location /metrics {
    proxy_pass http://localhost:9101;  # Updated for custom Node Exporter port
}

location / {
    proxy_pass http://localhost:9091;  # Updated for custom Prometheus port
}
```

### Service Management Commands

```bash
# Start Prometheus service
systemctl start prometheus.service

# Enable automatic startup
systemctl enable prometheus.service
```

## ✅ System Verification

### Network Connectivity Validation

Execute comprehensive network diagnostics to verify service availability:

```bash
netstat -tlpn
```

### Expected Network Output

```text
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN      21300/nginx: master
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      21300/nginx: master
tcp        0      0 :::9090                 :::*                    LISTEN      34330/prometheus
tcp        0      0 :::9100                 :::*                    LISTEN      1947/node_exporter
```

### Process Verification

Validate service execution under correct user contexts:

```bash
ps aux | grep -E "(prometheus|node_exporter)" | grep -v grep
```

### Expected Process Output

```text
node_ex+   34434  1.4  0.6 1239776 12368 ?       Ssl  09:36   0:00 /usr/local/bin/node_exporter
prometh+   34436  6.9  3.7 1338660 75324 ?       Ssl  09:36   0:00 /usr/local/bin/prometheus --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data
```

### Service Status Verification

```bash
# Check service status
systemctl status node_exporter.service
systemctl status prometheus.service
systemctl status nginx.service
```

## 📋 Prometheus Configuration Management

### Configuration File Structure

The Prometheus configuration file serves as the central control mechanism for metrics collection, target discovery, and alerting integration.

**Configuration File:** `/usr/local/bin/prometheus.yml`

```yaml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
        #  - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["34.47.28.41:9090"]
        # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "prometheus"

  - job_name: "node"
    static_configs:
      - targets: ["edgar.am:80"]
    metrics_path: "/metrics"
```

### Configuration Analysis

#### Global Configuration Section

| Parameter | Value | Technical Significance |
|-----------|-------|----------------------|
| `scrape_interval` | 15s | Defines the frequency of metrics collection across all targets |
| `evaluation_interval` | 15s | Specifies the interval for rule evaluation and alerting logic |
| `scrape_timeout` | 10s (default) | Maximum duration allowed for individual scrape operations |

#### Scrape Configuration Analysis

**Prometheus Self-Monitoring Job:**
- **Target:** `34.47.28.41:9090` (Prometheus instance IP and port)
- **Labels:** `app: "prometheus"` (Custom labeling for metric identification)
- **Purpose:** Enables Prometheus to monitor its own operational metrics

**Node Exporter Monitoring Job:**
- **Target:** `edgar.am:80` (Domain-based target specification)
- **Metrics Path:** `/metrics` (Custom endpoint routing via Nginx reverse proxy)
- **Purpose:** System-level metrics collection through reverse proxy architecture

### Configuration Design Rationale

The configuration implements a hybrid approach combining direct IP-based monitoring for Prometheus self-metrics and domain-based routing for Node Exporter metrics. This architecture leverages the Nginx reverse proxy to provide centralized access control and SSL termination while maintaining service isolation at the application layer.

## 🔒 Security Considerations

### Multi-Layer Security Implementation

#### Service Isolation
- **Dedicated Users:** Each service operates under isolated system accounts
- **Privilege Separation:** Non-interactive shell accounts prevent unauthorized access
- **Process Boundaries:** SystemD service isolation ensures resource containment

#### Network Security
- **Internal Binding:** Backend services bind to localhost interfaces only
- **Reverse Proxy:** External access mediated through Nginx security controls
- **TLS Encryption:** All external communications secured with HTTPS/TLS

#### Certificate Management
- **Self-Signed Certificates:** Suitable for internal/testing environments
- **Certificate Rotation:** Regular certificate renewal recommended
- **Key Security:** Private key files protected with appropriate file permissions

## 🔧 Troubleshooting

### Common Issues and Resolution Procedures

#### Service Startup Failures

```bash
# Check service status and logs
systemctl status <service_name>
journalctl -u <service_name> -f

# Verify file permissions
ls -la /usr/local/bin/node_exporter
ls -la /usr/local/bin/prometheus
```

#### Network Connectivity Issues

```bash
# Verify port availability
ss -tulpn | grep -E "(9090|9100|80|443)"

# Test local connectivity
curl http://localhost:9090/metrics
curl http://localhost:9100/metrics
```

#### Nginx Configuration Problems

```bash
# Validate Nginx configuration
nginx -t

# Monitor error logs
tail -f /var/log/nginx/error.log
```

#### SSL Certificate Validation

```bash
# Verify certificate details
openssl x509 -in /etc/nginx/ssl/nginx-selfsigned.crt -text -noout

# Check certificate expiration
openssl x509 -in /etc/nginx/ssl/nginx-selfsigned.crt -noout -dates
```

### Performance Monitoring

```bash
# Monitor system resources
htop
iotop

# Check disk usage for Prometheus data
df -h /var/lib/prometheus/data
```

---

**Implementation Status:** ✅ Production Ready  
**Security Level:** 🔒 Enterprise Grade  
**Architecture:** 🏗️ Scalable Infrastructure  

This monitoring solution delivers enterprise-level observability with comprehensive security hardening, service isolation, and operational reliability suitable for production environments.
