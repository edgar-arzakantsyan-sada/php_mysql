# 📊 Complete Monitoring Stack with Docker

A production-ready monitoring and logging solution using Prometheus, Grafana, Loki, Promtail, and Node Exporter, all containerized with Docker and secured with SSL.

## 🏗️ Architecture

This stack provides comprehensive system monitoring and log aggregation:

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation system
- **Promtail**: Log shipping agent
- **Node Exporter**: System metrics exporter
- **Nginx**: Reverse proxy with SSL termination

## 🌟 Features

- ✅ **SSL-secured access** with self-signed certificates
- ✅ **Automated service discovery** and configuration
- ✅ **Pre-configured datasources** for Grafana
- ✅ **Centralized logging** with Loki and Promtail
- ✅ **System metrics monitoring** with Node Exporter
- ✅ **Reverse proxy setup** for unified access
- ✅ **Persistent data storage** for metrics

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

### Step 2: Deploy the Stack

```bash
# Clone the repository
git clone https://github.com/edgar-arzakantsyan-sada/php_mysql.git
cd php_mysql

# Switch to the Loki branch
git checkout Loki

# Start all services
docker compose up -d
```

### Step 3: Verify Deployment

```bash
# Check running containers
docker compose ps

# View logs
docker compose logs -f
```

## 🌐 Access Points

Once deployed, access the services at:

| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **Grafana** | `https://edgar.am/` | 443 | Main dashboard interface |
| **Prometheus** | `https://edgar.am/prometheus/` | 443 | Metrics query interface |
| **Node Exporter** | `https://edgar.am/node_exporter/` | 443 | System metrics endpoint |
| **Loki** | `http://localhost:3100` | 3100 | Log aggregation API |

> **Note**: Update your `/etc/hosts` file or DNS to point `edgar.am` to your server IP.

## 📁 Project Structure

```
.
├── docker-compose.yml          # Main orchestration file
├── grafana/
│   ├── datasources.yaml       # Pre-configured data sources
│   └── Dockerfile             # Custom Grafana image
├── loki/
│   └── loki-config.yml        # Loki configuration
├── nginx/
│   ├── edgar.conf             # Nginx virtual host config
│   ├── nginx-selfsigned.crt   # SSL certificate
│   ├── nginx-selfsigned.key   # SSL private key
│   ├── access.log            # Access logs
│   └── error.log             # Error logs
├── node_exporter/
│   └── Dockerfile            # Node Exporter image
├── prometheus/
│   ├── Dockerfile            # Custom Prometheus image
│   ├── prometheus.yml        # Prometheus configuration
│   └── query.log            # Query logs
└── promtail/
    └── promtail-config.yml   # Promtail configuration
```

## ⚙️ Configuration

### Default Credentials

- **Grafana**: `admin` / `admin` (change on first login)

### SSL Certificates

The stack uses self-signed SSL certificates. For production use:

1. Replace certificates in `nginx/` directory
2. Update `nginx/edgar.conf` with your domain
3. Consider using Let's Encrypt for valid certificates

### Customization

- **Add metrics targets**: Edit `prometheus/prometheus.yml`
- **Configure alerts**: Add alerting rules to Prometheus
- **Custom dashboards**: Import via Grafana UI
- **Log sources**: Update `promtail/promtail-config.yml`

## 🔧 Management Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Update services
docker compose pull
docker compose up -d

# View logs
docker compose logs -f [service_name]

# Scale services (if needed)
docker compose up -d --scale prometheus=2
```

## 📊 Monitoring Capabilities

### System Metrics (Node Exporter)
- CPU usage and load
- Memory utilization
- Disk space and I/O
- Network statistics
- System uptime

### Application Metrics (Prometheus)
- Custom application metrics
- Service health checks
- Response times
- Error rates

### Log Management (Loki/Promtail)
- Centralized log collection
- Log parsing and labeling
- Real-time log streaming
- Log-based alerting

### Logs and Debugging

```bash
# Service-specific logs
docker compose logs grafana
docker compose logs prometheus
docker compose logs nginx

# Container inspection
docker inspect [container_name]
```

## 🔒 Security Considerations

- Change default Grafana credentials immediately
- Use proper SSL certificates in production
- Implement firewall rules for exposed ports
- Regular security updates for base images

**Made with ❤️ for reliable system monitoring**