# 📊 ELK Stack - Complete Log Analytics Solution

A production-ready Elasticsearch, Logstash, and Kibana (ELK) stack for centralized logging, log processing, and data visualization, all containerized with Docker and secured with SSL.

## 🏗️ Architecture

This comprehensive logging and analytics solution provides:

- **Elasticsearch**: Distributed search and analytics engine
- **Logstash**: Data processing pipeline for ingesting and transforming logs
- **Kibana**: Interactive data visualization and exploration platform
- **Nginx**: SSL-enabled reverse proxy for secure access

## 🌟 Features

- ✅ **Complete ELK Stack** with latest version 8.17.1
- ✅ **SSL-secured access** with self-signed certificates
- ✅ **Centralized log processing** with Logstash pipelines
- ✅ **Real-time data visualization** with Kibana dashboards
- ✅ **Persistent data storage** with Docker volumes
- ✅ **Service orchestration** with proper dependencies
- ✅ **Production-ready** configuration with restart policies
- ✅ **Memory-optimized** for efficient resource usage

## 📋 Prerequisites

- Ubuntu/Debian-based system
- Docker and Docker Compose
- Minimum 4GB RAM (recommended 8GB)
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

### Step 2: Deploy the ELK Stack

```bash
# Clone the repository
git clone https://github.com/edgar-arzakantsyan-sada/php_mysql.git
cd php_mysql

# Switch to the ELK branch (adjust branch name as needed)
git checkout main  # or your specific ELK branch

# Start all services
docker compose up -d
```

### Step 3: Verify Deployment

```bash
# Check running containers
docker compose ps

# View startup logs
docker compose logs -f

# Test Elasticsearch
curl -k https://edgar.am/elasticsearch/_cluster/health

# Test Kibana access
curl -k https://edgar.am/
```

## 🌐 Access Points

Once deployed, access the services at:

| Service | URL | Port | Description |
|---------|-----|------|-------------|
| **Kibana** | `https://edgar.am/` | 443 | Main analytics dashboard |
| **Elasticsearch** | `https://edgar.am/elasticsearch/` | 443 | Search API endpoint |
| **Logstash** | `localhost:5044` | 5044 | Log input endpoint |

> **Note**: Add `your-server-ip edgar.am` to your `/etc/hosts` file or configure DNS.

## 📁 Project Structure

```
.
├── docker-compose.yml          # ELK stack orchestration
├── logstash/
│   └── logstash.conf          # Log processing pipeline configuration
└── nginx/
    ├── edgar.conf             # Reverse proxy configuration
    ├── nginx-selfsigned.crt   # SSL certificate
    ├── nginx-selfsigned.key   # SSL private key
    ├── access.log            # HTTP access logs
    └── error.log             # HTTP error logs
```

## ⚙️ Service Configuration

### Elasticsearch Configuration
- **Version**: 8.17.1
- **Security**: Disabled for development (X-Pack security)
- **Memory**: 256MB heap size
- **Mode**: Single-node cluster
- **Port**: 9200

### Logstash Configuration
- **Version**: 8.17.1
- **Pipeline**: Custom configuration in `logstash/logstash.conf`
- **Input Port**: 5044 (Beats protocol)
- **Memory**: 256MB heap size

### Kibana Configuration
- **Version**: 8.17.1
- **Elasticsearch URL**: Internal connection to Elasticsearch
- **Port**: 5601
- **Interface**: Web-based analytics platform

## 🔧 Management Commands

```bash
# Start the ELK stack
docker compose up -d

# Stop all services
docker compose down

# Restart specific service
docker compose restart elasticsearch

# View real-time logs
docker compose logs -f kibana

# Update services
docker compose pull && docker compose up -d

# Scale Logstash (if needed)
docker compose up -d --scale logstash=2

# Remove everything including data
docker compose down -v
```

## 📊 Log Processing Pipeline

### Sample Logstash Configuration

Create or modify `logstash/logstash.conf`:

```ruby
input {
  beats {
    port => 5044
  }
  
  # HTTP input for direct log submission
  http {
    port => 8080
  }
  
  # File input for local log files
  file {
    path => "/var/log/*.log"
    start_position => "beginning"
  }
}

filter {
  # Parse common log formats
  if [fields][log_type] == "nginx" {
    grok {
      match => { 
        "message" => "%{COMBINEDAPACHELOG}" 
      }
    }
    
    date {
      match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
    }
  }
  
  # Add custom fields
  mutate {
    add_field => { "environment" => "production" }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
  
  # Debug output
  stdout { 
    codec => rubydebug 
  }
}
```

## 🎯 Getting Started with ELK

### 1. Access Kibana
1. Navigate to `https://edgar.am/`
2. Wait for Kibana to initialize (may take 2-3 minutes)
3. No authentication required (development setup)

### 2. Create Index Patterns
1. Go to **Management** > **Stack Management**
2. Select **Index Patterns**
3. Create pattern: `logs-*`
4. Choose `@timestamp` as time field

### 3. Send Sample Logs
```bash
# Send test log via HTTP
curl -X POST "localhost:8080" \
  -H "Content-Type: application/json" \
  -d '{"message":"Test log entry","level":"info","service":"test"}'

# Check if data appears in Elasticsearch
curl -k https://edgar.am/elasticsearch/logs-*/_search?pretty
```

### 4. Create Visualizations
- **Discover**: Explore raw log data
- **Dashboard**: Create custom dashboards
- **Visualizations**: Build charts and graphs
- **Canvas**: Create dynamic presentations


**Elasticsearch won't start:**
```bash
# Check system requirements
sudo sysctl vm.max_map_count
# If less than 262144:
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf

# Check memory
free -h
# Ensure at least 2GB available
```

**Kibana shows "Kibana server is not ready yet":**
```bash
# Wait for Elasticsearch to be fully ready
docker compose logs elasticsearch
# Look for "started" message

# Check Elasticsearch health
curl -k https://edgar.am/elasticsearch/_cluster/health
```

**Logstash pipeline errors:**
```bash
# Check configuration syntax
docker compose exec logstash logstash --config.test_and_exit \
  -f /logstash_dir/logstash.conf

# View detailed logs
docker compose logs -f logstash
```

**No data in Kibana:**
```bash
# Verify Logstash is receiving data
docker compose logs logstash | grep "Pipeline started"

# Check Elasticsearch indices
curl -k https://edgar.am/elasticsearch/_cat/indices?v

# Test Logstash input
echo '{"test":"message"}' | nc localhost 5044
```

**High memory usage:**
```bash
# Adjust heap sizes in docker-compose.yml
environment:
  - ES_JAVA_OPTS=-Xmx512m -Xms512m  # Increase for Elasticsearch
  - LS_JAVA_OPTS=-Xmx512m -Xms512m  # Increase for Logstash
```

**Slow queries:**
- Create appropriate index templates
- Use index lifecycle management
- Optimize Logstash filters
- Consider index sharding strategy

## 📈 Production Recommendations

### Security Enhancements
```yaml
# Enable X-Pack security (in production)
environment:
  - xpack.security.enabled=true
  - ELASTIC_PASSWORD=your_secure_password
```

## 🔒 Security Considerations

### Development vs Production
**Current Setup (Development)**:
- X-Pack security disabled
- No authentication required
- HTTP connections allowed

**Production Recommendations**:
1. Enable X-Pack security
2. Configure SSL/TLS certificates
3. Set up user authentication
4. Implement role-based access control
5. Use secrets management
6. Configure network security

## 📚 Sample Use Cases

### 1. Application Log Analysis
- Centralize logs from multiple applications
- Parse structured and unstructured logs
- Create alerts for error patterns
- Monitor application performance metrics

### 2. Security Monitoring
- Collect security logs from firewalls, IDS/IPS
- Detect suspicious patterns and anomalies
- Create security dashboards
- Implement automated alerting

### 3. Infrastructure Monitoring
- Aggregate system logs from multiple servers
- Monitor resource usage patterns
- Track deployment and configuration changes
- Create operational dashboards

---

**Powering log analytics and data insights** 🔍✨