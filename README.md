# Grafana with Prometheus and Node Exporter Setup Script

A comprehensive bash script for automated installation and configuration of Grafana, Prometheus, and Node Exporter with secure HTTPS proxy integration on Ubuntu 24.04 LTS.

## 🚀 Features

### Port Flexibility
- Configure all services on any available port you want
- Automatic port availability checking
- Port range validation (2000-65535)

### Reconfiguration Support
- Rerun the script to reconfigure any service
- Configure all services if needed
- Service status detection and smart handling

### Multiple Versions Available
- Choose between multiple versions of services during installation
- Default version selection for quick setup
- Fallback to latest stable version

### Secure HTTPS Connection with Flexible Proxy Server
- **Nginx Proxy Service** on top of the infrastructure
- No need to open individual ports - everything works internally
- **Automatic redirection** to HTTPS connection
- **Trusted TLS Certificates** with self-signed certificate generation
- Domain-based routing with local DNS resolution

## 📋 Requirements

- **Operating System**: Ubuntu 24.04 LTS
- **Internet Access**: Required for downloading service binaries
- **Sudo Privileges**: Required for system configuration
- **Domain**: Uses `edgar.am` domain (configured in /etc/hosts)

## 🛠️ Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```

3. Run the setup script:
   ```bash
   sudo ./setup.sh
   ```

## 📖 How It Works

### Step-by-Step Process

#### 1. Initial System Checks
The script first validates and installs necessary system commands and services:
- `wget` - for downloading service binaries
- `openssl` - for SSL certificate generation
- `curl` - for HTTP requests
- `nginx` - for reverse proxy
- `net-tools` - for network diagnostics

#### 2. Service Status Detection
For each service (node_exporter, prometheus, grafana), the script:
- **Running Service**: Asks if reconfiguration is needed
- **Installed but Stopped**: Options to start, reconfigure, or skip
- **Not Installed**: Prompts for fresh installation

#### 3. Version Selection and Installation
- Creates dedicated system users for each service
- Presents available versions for selection (default is option 1)
- Downloads and extracts service binaries
- Configures service-specific settings

#### 4. Port Configuration
- Interactive port selection with validation
- Ensures ports are in valid range (2000-65535)
- Checks port availability using `netstat`
- Prevents port conflicts

#### 5. Service Configuration
Each service gets configured with:
- **Prometheus**: TSDB storage, web interface, external URL routing
- **Grafana**: Custom configuration, datasource provisioning
- **Node Exporter**: Basic metrics collection setup

#### 6. Systemd Integration
- Creates systemd service files for each component
- Enables auto-start on system boot
- Provides service management capabilities

#### 7. Nginx Proxy Setup
- Detects running service ports automatically
- Generates SSL certificates
- Configures reverse proxy with HTTPS redirection
- Updates system certificate store
- Configures local DNS resolution

## 🔧 Configuration Files

### Required Files
- `prometheus.yml` - Prometheus configuration
- `datasources.yaml` - Grafana datasource configuration
- `edgar.conf` - Nginx proxy configuration template
- Service version lists: `node_exporter`, `prometheus`, `grafana`

### Generated Files
- `/etc/systemd/system/<service>.service` - Systemd service definitions
- `/etc/nginx/conf.d/edgar.conf` - Nginx proxy configuration
- `/etc/nginx/ssl/nginx*` - SSL certificates
- `/etc/hosts` - Local DNS entry for edgar.am

## 🌐 Access Points

After successful installation, access your services via:

- **Grafana Dashboard**: `https://edgar.am/`
- **Prometheus Web UI**: `https://edgar.am/prometheus`
- **Node Exporter Metrics**: `https://edgar.am/node_exporter`

## 🔒 Security Features

- **HTTPS Only**: Automatic HTTP to HTTPS redirection
- **Self-Signed Certificates**: Trusted by system certificate store
- **Service Isolation**: Dedicated system users for each service
- **Internal Communication**: Services communicate internally, only Nginx exposed
- **Port Security**: No direct external port exposure

## 🔄 Reconfiguration

To reconfigure any service:
1. Run the script again: `sudo ./setup.sh`
2. Choose reconfiguration when prompted
3. Select new ports or versions as needed
4. The script will handle service restart and proxy reconfiguration

## 📊 Monitoring Stack

- **Node Exporter**: System and hardware metrics collection
- **Prometheus**: Metrics storage and querying
- **Grafana**: Visualization and dashboarding
- **Nginx**: Reverse proxy with SSL termination

## 🐛 Troubleshooting

### Common Issues
- **Port conflicts**: Script will detect and prompt for alternative ports
- **Service startup failures**: Check systemd logs with `journalctl -u <service>`
- **Certificate issues**: Certificates are regenerated on each run
- **Permission errors**: Ensure script is run with sudo privileges

### Log Locations
- **Systemd logs**: `journalctl -u <service_name>`
- **Nginx logs**: `/var/log/nginx/error.log` and `/var/log/nginx/access.log`
- **Service logs**: Check individual service documentation

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For issues and questions:
- Create an issue in the GitHub repository
- Check existing documentation
- Review systemd logs for service-specific problems

---

**Note**: This script is designed for development and testing environments. For production use, consider implementing additional security measures and proper certificate management.