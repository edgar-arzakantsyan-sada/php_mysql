# 📊 Essential Monitoring Stack with Docker

A streamlined, production-ready monitoring solution using Prometheus, Grafana, and Node Exporter, all containerized with Docker and secured with SSL reverse proxy.

## 🏗️ Architecture

This lightweight monitoring stack provides essential system monitoring and visualization:

- **Prometheus**: Metrics collection and time-series storage
- **Grafana**: Interactive dashboards and visualization
- **Node Exporter**: System and hardware metrics exporter
- **Nginx**: SSL-enabled reverse proxy

## 🌟 Features

- ✅ **SSL-secured access** with self-signed certificates
- ✅ **Pre-configured Grafana datasources** for instant setup
- ✅ **System metrics monitoring** with Node Exporter
- ✅ **Service dependencies** for proper startup order
- ✅ **Persistent metrics storage** with Docker volumes
- ✅ **Reverse proxy configuration** for unified access
- ✅ **Production-ready** with restart policies

## 📋 Prerequisites

- Ubuntu/Debian-based system
- Docker and Docker Compose
- Root or sudo privileges
- Internet connection for downloading images

## 🚀 Quick Start

### Step 1: Install Docker

```bash
# Update system packages
sudo apt-get update
sudo apt-get install ca-certificates curl

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 2: Deploy the Monitoring Stack

```bash
# Clone the repository
git clone https://github.com/edgar-arzakantsyan-sada/php_mysql.git
cd php_mysql

# Switch to the compose branch
git checkout compose

# Start all services
docker compose up -d
```

### Step 3: Verify Deployment

```bash
# Check running containers
docker compose ps

# View service logs
docker compose logs -f

# Check service health
curl -k https://edgar.am/
```

## 🌐 Access Points

Once deployed, access the services at:

| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **Grafana** | `https://edgar.am/` | 443 | Main monitoring dashboard |
| **Prometheus** | `https://edgar.am/prometheus/` | 443 | Metrics query interface |
| **Node Exporter** | `https://edgar.am/node_exporter/` | 443 | System metrics endpoint |

> **Note**: Add `your-server-ip edgar.am` to your `/etc/hosts` file or configure DNS.

## 📁 Project Structure

```
.
├── docker-compose.yml          # Service orchestration
├── grafana/
│   ├── datasources.yaml       # Auto-configured Prometheus datasource
│   └── Dockerfile             # Custom Grafana build
├── nginx/
│   ├── edgar.conf             # Reverse proxy configuration
│   ├── nginx-selfsigned.crt   # SSL certificate
│   ├── nginx-selfsigned.key   # SSL private key
│   ├── access.log            # HTTP access logs
│   └── error.log             # HTTP error logs
├── node_exporter/
│   └── Dockerfile            # Node Exporter build
└── prometheus/
    ├── Dockerfile            # Custom Prometheus build
    ├── prometheus.yml        # Monitoring targets configuration
    └── query.log            # Prometheus query logs
```

## ⚙️ Service Configuration

### Service Dependencies

The stack uses proper dependency management:
- **Prometheus** waits for Node Exporter
- **Grafana** waits for Prometheus and Node Exporter
- **Nginx** waits for all monitoring services

### Default Settings

- **Grafana**: Default credentials `admin` / `admin`
- **Prometheus**: Scrapes Node Exporter every 15 seconds
- **Node Exporter**: Exposes system metrics on port 9100
- **Nginx**: SSL redirect from HTTP to HTTPS

## 🔧 Management Commands

```bash
# Start the stack
docker compose up -d

# Stop all services
docker compose down

# Restart a specific service
docker compose restart grafana

# View real-time logs
docker compose logs -f prometheus

# Update and restart services
docker compose pull && docker compose up -d

# Remove everything (including volumes)
docker compose down -v
```

## 📊 Available Metrics

### System Monitoring (Node Exporter)
- **CPU**: Usage, load average, frequency
- **Memory**: RAM usage, swap, buffers/cache
- **Disk**: Space usage, I/O operations, read/write speeds
- **Network**: Interface statistics, packet counts
- **System**: Uptime, processes, file descriptors

### Prometheus Metrics
- **Scraping**: Target health and timing
- **Storage**: TSDB statistics
- **Query**: Performance metrics
- **Rules**: Evaluation timing

## 🎯 Getting Started with Monitoring

### 1. Access Grafana
1. Navigate to `https://edgar.am/`
2. Login with `admin` / `admin`
3. Change the default password
4. Prometheus datasource is pre-configured


## 📈 Performance Tuning

### Prometheus Configuration
```yaml
# Adjust scrape intervals in prometheus.yml
scrape_configs:
  - job_name: 'node'
    scrape_interval: 15s  # Increase for less frequent collection
    static_configs:
      - targets: ['node_exporter_instance:9100']
```

## 🔒 Security Recommendations

### Production Deployment
1. **Replace self-signed certificates** with valid SSL certificates
2. **Change default credentials** immediately
3. **Configure firewall rules** to restrict access
4. **Enable HTTPS-only** access
5. **Regular security updates** for Docker images
6. **Implement authentication** for Prometheus if exposed

---

**Built for reliable system monitoring and observability** 🚀