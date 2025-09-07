# Automated Prometheus & Node Exporter Setup Script

This bash script helps users with a brand new server to quickly set up a working Prometheus instance with Node Exporter integration, complete with Nginx reverse proxy and SSL configuration.

## Overview

The script automates the complete setup of:
- Nginx web server with SSL certificates
- Node Exporter for system metrics collection  
- Prometheus monitoring server
- Systemd service configurations
- Reverse proxy configuration for secure access

## What the Script Does

### 1. Nginx Installation and Configuration

```bash
echo "Installing and configuring Nginx ....."
apt update && apt install nginx -y
```
- Updates package repositories
- Installs Nginx web server

### 2. Nginx Virtual Host Setup

The script creates `/etc/nginx/conf.d/prometheus.conf` with two server blocks:

**HTTP to HTTPS Redirect:**
```nginx
server{
    listen 80;
    server_name edgar.am;
    return 301 https://$host$request_uri;
}
```
- Listens on port 80
- Redirects all HTTP traffic to HTTPS

**HTTPS Server Block:**
```nginx
server{
    listen 443 ssl;
    server_name edgar.am;
    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
    
    location /node_exporter {
        proxy_pass http://localhost:9100/;
    }
    location /node_exporter/metrics {
        proxy_pass http://localhost:9100/metrics;
    }
    location / {
        proxy_pass http://localhost:9090;
    }
}
```
- Listens on port 443 with SSL
- Proxies `/node_exporter` requests to Node Exporter (port 9100)
- Proxies all other requests to Prometheus (port 9090)

### 3. SSL Certificate Creation

```bash
mkdir /etc/nginx/ssl
```
Creates SSL directory and generates:
- **Self-signed certificate** (`nginx-selfsigned.crt`)
- **Private key** (`nginx-selfsigned.key`)

The script embeds a complete SSL certificate for `edgar.am` domain and installs it to the system's trusted certificate store.

### 4. Node Exporter Installation

```bash
/usr/bin/wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
mv node_exporter-1.8.2.linux-amd64/node_exporter/* /usr/local/bin/
```
- Downloads Node Exporter v1.8.2
- Extracts and moves binaries to `/usr/local/bin/`

### 5. Node Exporter System User

```bash
/usr/sbin/useradd -rs /bin/false node_exporter
```
Creates a system user `node_exporter` with:
- No shell access (`/bin/false`)
- System account (`-r`)
- No home directory creation (`-s`)

### 6. Node Exporter Systemd Service

Creates `/etc/systemd/system/node_exporter.service`:
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
- Runs as `node_exporter` user
- Starts after network is available
- Enables automatic startup

### 7. Prometheus Installation

```bash
/usr/sbin/useradd -rs /bin/false prometheus
mkdir -p /var/lib/prometheus/data
chown -R prometheus.prometheus /var/lib/prometheus/
```
- Creates `prometheus` system user
- Sets up data directory with proper ownership

```bash
/usr/bin/wget wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
tar xvf prometheus-3.5.0.linux-amd64.tar.gz
mv prometheus-3.5.0.linux-amd64/* /usr/local/bin/
```
- Downloads Prometheus v3.5.0
- Extracts and installs to `/usr/local/bin/`

### 8. Prometheus Systemd Service

Creates `/etc/systemd/system/prometheus.service`:
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

### 9. Prometheus Configuration

Creates `/usr/local/bin/prometheus.yml` with:

**Global Settings:**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
```
- Scrapes metrics every 15 seconds
- Evaluates rules every 15 seconds

**Scrape Configurations:**
```yaml
scrape_configs:
  - job_name: "prometheus"
    scheme: https
    tls_config:
      insecure_skip_verify: true 
    static_configs:
      - targets: ["edgar.am:80"]
        labels:
          app: "prometheus"

  - job_name: "node"
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ["edgar.am:80"]
    metrics_path: "/node_exporter/metrics"
```
- Configures Prometheus to scrape itself
- Configures Node Exporter metrics collection
- Uses HTTPS with self-signed certificate verification disabled

### 10. Service Startup and Cleanup

```bash
systemctl daemon-reload
systemctl start prometheus.service
systemctl enable prometheus.service
```
- Reloads systemd configuration
- Starts Prometheus service
- Enables automatic startup on boot

```bash
rm -rf /home/edgararzakantsyan6/node* /home/edgararzakantsyan6/prome*
```
- Cleans up downloaded installation files

## Usage

1. **Make the script executable:**
   ```bash
   chmod +x setup-prometheus.sh
   ```

2. **Run as root:**
   ```bash
   sudo ./setup-prometheus.sh
   ```

3. **Access your services:**
   - Prometheus Web UI: `https://edgar.am/`
   - Node Exporter Metrics: `https://edgar.am/node_exporter/metrics`

## Prerequisites

- Fresh Ubuntu/Debian server
- Root or sudo access
- Domain `edgar.am` pointing to your server (or modify the script for your domain)

## Security Notes

- The script uses **self-signed SSL certificates** - not suitable for production
- SSL verification is disabled in Prometheus configuration
- For production use, replace with proper SSL certificates from a trusted CA

## Customization

To use with your own domain:
1. Replace all instances of `edgar.am` with your domain
2. Generate new SSL certificates for your domain
3. Update the certificate content in the script

## Services Created

After successful execution, you'll have:
- **nginx**: Web server and reverse proxy
- **node_exporter**: System metrics collector (port 9100)
- **prometheus**: Monitoring server (port 9090)

All services are configured to start automatically on system boot.
