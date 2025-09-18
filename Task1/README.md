# Docker WordPress Setup Guide

A comprehensive guide for setting up a WordPress development environment using Docker containers with MySQL database backend.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
  - [1. Docker Installation](#1-docker-installation)
  - [2. Network Configuration](#2-network-configuration)
  - [3. MySQL Container Setup](#3-mysql-container-setup)
  - [4. Database Configuration](#4-database-configuration)
  - [5. WordPress Container Deployment](#5-wordpress-container-deployment)
- [Verification](#verification)
- [Configuration Details](#configuration-details)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## 🌟 Overview

This repository provides step-by-step instructions for deploying a WordPress application using Docker containers. The setup includes:

- **MySQL Database**: Persistent data storage for WordPress
- **WordPress Application**: Latest WordPress version running on Apache
- **Custom Docker Network**: Secure communication between containers
- **Port Mapping**: Access WordPress through localhost

## ⚡ Prerequisites

- Ubuntu/Debian-based Linux distribution
- Sudo privileges
- Internet connection for downloading Docker images

## 🚀 Installation Steps

### 1. Docker Installation

First, we'll install Docker CE (Community Edition) with all necessary components:

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

This installs:
- `docker-ce`: Docker Community Edition engine
- `docker-ce-cli`: Command-line interface
- `containerd.io`: Container runtime
- `docker-buildx-plugin`: Extended build capabilities
- `docker-compose-plugin`: Multi-container application management

### 2. Network Configuration

Create a custom Docker network to enable secure communication between containers:

```bash
docker network create my-network
```

**Why create a custom network?**
- Containers can communicate using container names instead of IP addresses
- Provides network isolation from other Docker containers
- Enables automatic DNS resolution between containers

### 3. MySQL Container Setup

Deploy the MySQL database container with the following configuration:

```bash
docker run --name mysql-instance --network my-network -e MYSQL_ROOT_PASSWORD=EdJan -d mysql:latest
```

**Container Configuration:**
- `--name mysql-instance`: Assigns a friendly name to the container
- `--network my-network`: Connects to our custom network
- `-e MYSQL_ROOT_PASSWORD=EdJan`: Sets the MySQL root password
- `-d`: Runs container in detached mode (background)
- `mysql:latest`: Uses the latest MySQL Docker image

### 4. Database Configuration

Create the WordPress database within the MySQL container:

```bash
docker exec -it mysql-instance mysql -u root -p
```

When prompted, enter the password: `EdJan`

Execute the following SQL command:

```sql
CREATE Database wordpress;
exit
```

**What this does:**
- `docker exec -it`: Executes an interactive command inside the running container
- `mysql -u root -p`: Connects to MySQL as root user with password prompt
- `CREATE Database wordpress;`: Creates a database named 'wordpress'

### 5. WordPress Container Deployment

Launch the WordPress container and connect it to the MySQL database:

```bash
docker run --name wordpress-instance --network my-network -p 80:80 -d wordpress:latest
```

**Container Configuration:**
- `--name wordpress-instance`: Names the WordPress container
- `--network my-network`: Connects to the same network as MySQL
- `-p 80:80`: Maps host port 80 to container port 80
- `-d`: Runs in background
- `wordpress:latest`: Uses the latest WordPress Docker image

## ✅ Verification

After completing the installation:

1. **Check running containers:**
   ```bash
   docker ps
   ```

2. **Access WordPress:**
   - Open your web browser
   - Navigate to `http://localhost`
   - Complete the WordPress setup wizard

3. **WordPress Database Configuration:**
   - Database Name: `wordpress`
   - Username: `root`
   - Password: `EdJan`
   - Database Host: `mysql-instance`

## ⚙️ Configuration Details

| Component | Container Name | Network | Port | Image |
|-----------|---------------|---------|------|-------|
| MySQL | mysql-instance | my-network | 3306 (internal) | mysql:latest |
| WordPress | wordpress-instance | my-network | 80:80 | wordpress:latest |

### Environment Variables

- **MySQL Root Password**: `EdJan` (⚠️ Change in production)
- **WordPress Database**: `wordpress`

## 🔧 Troubleshooting

### Common Issues

1. **Port 80 already in use:**
   ```bash
   docker run --name wordpress-instance --network my-network -p 8080:80 -d wordpress:latest
   ```
   Then access via `http://localhost:8080`

2. **Check container logs:**
   ```bash
   docker logs mysql-instance
   docker logs wordpress-instance
   ```

3. **Restart containers:**
   ```bash
   docker restart mysql-instance wordpress-instance
   ```

### Container Management Commands

```bash
# Stop containers
docker stop wordpress-instance mysql-instance

# Start containers
docker start mysql-instance wordpress-instance

# Remove containers (⚠️ This will delete data)
docker rm wordpress-instance mysql-instance

# Remove network
docker network rm my-network
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📝 Notes

- **Security**: This setup uses default passwords suitable for development only
- **Data Persistence**: Consider using Docker volumes for production deployments
- **SSL/HTTPS**: Additional configuration required for secure connections
- **Backup**: Regular database backups recommended for production use

---

**Happy Dockerizing!** 🐳

For more information, visit the official documentation:
- [Docker Documentation](https://docs.docker.com/)
- [WordPress Docker Image](https://hub.docker.com/_/wordpress)
- [MySQL Docker Image](https://hub.docker.com/_/mysql)