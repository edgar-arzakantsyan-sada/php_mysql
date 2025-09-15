# Grafana with Prometheus and Node Exporter Setup Script

A comprehensive bash script for automated installation and configuration of Grafana, Prometheus, and Node Exporter with secure HTTPS proxy integration on Ubuntu 24.04 LTS.

## Features

### Intelligent Service Management
- Automatic service status detection with contextual prompts
- Smart handling of installed but stopped services
- Reconfiguration support for running services
- Graceful exit options for user control

### Port Flexibility
- Configure all services on any available port you want
- Automatic port availability checking with netstat validation
- Port range validation (2000-65535)
- Real-time port conflict detection

### Version Selection System
- Choose between multiple versions of services during installation
- Numbered selection interface with default option (1)
- Automatic fallback to latest stable version on selection failure
- Service-specific version files support

### Secure HTTPS Connection with Automatic Proxy Setup
- **Nginx Proxy Service** with automatic port detection
- No need to open individual ports - everything works internally
- **Automatic HTTP to HTTPS redirection**
- **Self-signed TLS Certificate generation and system integration**
- Domain-based routing with automatic local DNS resolution
- SSL certificate trust store integration

### Enterprise Service Architecture
- **Prometheus**: Advanced configuration with external URL routing and web route prefix
- **Grafana**: Datasource provisioning with custom configuration management
- **Node Exporter**: System metrics collection with flexible binding options

## Requirements

- **Operating System**: Ubuntu 24.04 LTS
- **Privileges**: sudo access required
- **Internet Access**: Required for downloading service binaries
- **Domain Configuration**: Uses `edgar.am` domain (automatically configured in /etc/hosts)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/edgar-arzakantsyan-sada/php_mysql.git
   cd php_mysql
   git checkout Ed
   cd Grafana
   ```

2. Run the setup script:
   ```bash
   ./best.sh
   ```

## How It Works

### Phase 1: System Preparation

#### Dependency Management (`start_checks`)
The script validates and installs essential system components:
- **wget**: Service binary downloads
- **openssl**: SSL certificate generation
- **tee**: Configuration file creation
- **curl**: HTTP connectivity testing
- **nginx**: Reverse proxy server
- **net-tools**: Network diagnostics (netstat command)

Error handling includes automatic repository updates on package installation failures.

### Phase 2: Service Status Intelligence

#### Smart Service Detection (`message`)
For each service (node_exporter, prometheus, grafana), the script performs contextual analysis:

**Running Service Detection**:
```bash
sudo systemctl status $service.service
```
- **Status**: Active/Running
- **Action**: Prompts for reconfiguration option
- **Flow**: Proceeds to port configuration if confirmed

**Installed but Stopped Service**:
```bash
[ -f /etc/systemd/system/$service.service ]
```
- **Status**: Service files exist, service inactive
- **Options**: Start/Reconfigure/Pass [s/r/p]
- **Flexibility**: Multiple resolution paths

**Fresh Installation Required**:
- **Status**: No service files detected
- **Action**: Installation workflow initiation
- **User Control**: Installation confirmation required

### Phase 3: Installation and Version Management

#### User Creation and Version Selection (`install`)
```bash
# System user creation with security isolation
grep $service /etc/passwd || sudo useradd -rs /bin/false $service

# Interactive version selection with fallback mechanism
cat -n $service  # Display numbered version list
/usr/bin/wget $(cat $service | head -$RESPONSE | tail -1) || /usr/bin/wget $(head -1 $service)
```

**Security Implementation**:
- `-r`: System account (UID < 1000)
- `-s /bin/false`: No shell access
- Service isolation principle

### Phase 4: Port Configuration and Validation

#### Interactive Port Management (`port`)
```bash
while true; do
    read -p "Please enter the port number (2000-65535): "
    # Numeric validation
    [[ "$REPLY" =~ ^[0-9]+$ ]] || continue
    
    # Range validation
    [ "$REPLY" -ge 2000 ] && [ "$REPLY" -le 65535 ] || continue
    
    # Availability check
    sudo netstat -tulpn | grep ":$REPLY" || break
done
```

**Validation Layers**:
1. **Input Type**: Numeric-only validation
2. **Range Check**: Port range 2000-65535
3. **Availability**: Real-time port conflict detection
4. **Confirmation**: User feedback on port availability

### Phase 5: Service-Specific Configuration

#### Advanced Service Configuration (`conf`)

**Prometheus Configuration**:
```bash
EXECSTART="/usr/local/bin/prometheus \
    --config.file=/usr/local/bin/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/data \
    --web.listen-address=0.0.0.0:$PORT \
    --web.external-url=https://edgar.am/prometheus \
    --web.route-prefix=/prometheus"
```

**Grafana Configuration**:
```bash
EXECSTART="/usr/local/grafana/bin/grafana server \
    --config=/usr/local/grafana/conf/defaults.ini \
    --homepath=/usr/local/grafana"

# Dynamic port configuration in defaults.ini
sudo sed -i "s/3000/$PORT/g" /usr/local/grafana/conf/defaults.ini
```

**Node Exporter Configuration**:
```bash
EXECSTART="/usr/local/bin/node_exporter --web.listen-address=0.0.0.0:$PORT"
```

#### SystemD Integration
```ini
[Unit]
Description=$service
After=network.target

[Service]
User=$service
Group=$service
Type=simple
ExecStart=$EXECSTART

[Install]
WantedBy=multi-user.target
```

### Phase 6: Nginx Proxy Automation

#### Intelligent Proxy Configuration (`nginx_setup`)

**Automatic Port Detection**:
```bash
PORT1=$(sudo netstat -ltnp | grep node_exporter | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
PORT2=$(sudo netstat -ltnp | grep prometheus | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)  
PORT3=$(sudo netstat -ltnp | grep grafana | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
```

**Dynamic Configuration Generation**:
```bash
sed "s/PORT1/$PORT1/g; s/PORT2/$PORT2/g; s/PORT3/$PORT3/g;" edgar.conf | sudo tee /etc/nginx/conf.d/edgar.conf
```

**SSL Certificate Integration**:
```bash
# SSL certificate deployment
sudo mkdir -p /etc/nginx/ssl
sudo mv nginx* /etc/nginx/ssl

# System certificate store integration
sudo cp /etc/nginx/ssl/nginx-selfsigned.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates

# Local DNS resolution
echo "127.0.0.1 edgar.am" | sudo tee -a /etc/hosts
```

## Configuration Files

### Required Configuration Files
- **`prometheus.yml`**: Prometheus scrape configuration and global settings
- **`datasources.yaml`**: Grafana datasource provisioning configuration
- **`edgar.conf`**: Nginx reverse proxy template with PORT placeholders
- **Version Files**: `node_exporter`, `prometheus`, `grafana` (containing download URLs)

### Auto-Generated Files
- **`/etc/systemd/system/<service>.service`**: SystemD service definitions
- **`/etc/nginx/conf.d/edgar.conf`**: Dynamic Nginx configuration
- **`/etc/nginx/ssl/nginx*`**: SSL certificates and keys
- **`/etc/hosts`**: Local DNS entry for edgar.am domain

## Access Points

After successful installation, access your complete monitoring stack:

- **Grafana Dashboard**: `https://edgar.am/` (Primary visualization interface)
- **Prometheus Web UI**: `https://edgar.am/prometheus` (Metrics exploration and querying)
- **Node Exporter Metrics**: `https://edgar.am/node_exporter` (Raw system metrics endpoint)

## Security Architecture

### Multi-Layer Security Implementation
- **HTTPS Enforcement**: Automatic HTTP to HTTPS redirection
- **Certificate Management**: Self-signed certificates integrated into system trust store
- **Service Isolation**: Dedicated system users with no shell access
- **Internal Communication**: Services communicate via localhost, only Nginx exposed externally
- **Port Security**: No direct external access to service ports

### Network Security Design
```
External Request (HTTPS) → Nginx (443) → Internal Services (Custom Ports)
                                    ↓
                            [Prometheus:PORT2]
                            [Grafana:PORT3]
                            [Node Exporter:PORT1]
```

## Reconfiguration Workflow

### Service Reconfiguration Process
1. **Execute Script**: `./best.sh`
2. **Service Detection**: Script detects existing services automatically
3. **Reconfiguration Prompt**: Choose reconfiguration when prompted for running services
4. **Port Selection**: Select new ports with availability validation
5. **Automatic Updates**: Script handles service restart and proxy reconfiguration
6. **Validation**: Nginx configuration test and reload

### Reconfiguration Scenarios
- **Port Changes**: Update service ports without reinstallation
- **Version Updates**: Upgrade to newer service versions
- **Configuration Modifications**: Update service-specific settings
- **SSL Certificate Renewal**: Update certificates and reload services

## Monitoring Stack Architecture

### Component Overview
| Component | Purpose | Configuration |
|-----------|---------|---------------|
| **Node Exporter** | System and hardware metrics collection | Custom port binding, comprehensive system metrics |
| **Prometheus** | Metrics storage, querying, and alerting | TSDB storage, external URL routing, web prefix configuration |
| **Grafana** | Data visualization and dashboarding | Datasource provisioning, custom configuration management |
| **Nginx** | Reverse proxy with SSL termination | Dynamic port detection, HTTPS enforcement, certificate management |

### Data Flow Architecture
```
System Metrics → Node Exporter → Prometheus → Grafana Dashboard
                                      ↑              ↓
                               Storage & Query    Visualization
                                      ↑              ↓
                                 Nginx Proxy ← HTTPS Clients
```

## Troubleshooting

### Common Issues and Diagnostics

#### Service Status Verification
```bash
# Check all service status
sudo systemctl status node_exporter prometheus grafana nginx

# Check service logs
sudo journalctl -u <service_name> -f

# Verify port bindings
sudo netstat -tulpn | grep -E "(node_exporter|prometheus|grafana)"
```

#### Network Connectivity Testing
```bash
# Test internal connectivity
curl http://localhost:<port>/metrics        # Node Exporter
curl http://localhost:<port>/api/v1/status  # Prometheus
curl http://localhost:<port>/api/health     # Grafana

# Test external HTTPS access
curl -k https://edgar.am/
curl -k https://edgar.am/prometheus
curl -k https://edgar.am/node_exporter
```

#### SSL Certificate Validation
```bash
# Check certificate details
openssl x509 -in /etc/nginx/ssl/nginx-selfsigned.crt -text -noout

# Verify certificate in trust store
ls -la /usr/local/share/ca-certificates/nginx-selfsigned.crt

# Test Nginx configuration
sudo nginx -t
```

### Log Analysis Locations
- **SystemD Service Logs**: `journalctl -u <service_name>`
- **Nginx Access Logs**: `/var/log/nginx/access.log`
- **Nginx Error Logs**: `/var/log/nginx/error.log`
- **Service-Specific Logs**: Check individual service documentation for additional log locations

