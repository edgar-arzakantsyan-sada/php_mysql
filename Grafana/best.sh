#!/bin/bash

# Grafana, Prometheus, and Node Exporter Setup Script
# This script automates the installation and configuration of a complete monitoring stack
# with secure HTTPS proxy integration using Nginx

# Function: start_checks
# Purpose: Verify and install necessary system commands and dependencies
# Dependencies: wget, openssl, tee, curl, nginx, net-tools

set -e

start_checks(){
        echo "Checking and installing necessary commands if needed...."
        # Check and install basic utilities required for the script
    for i in wget openssl tee curl nginx; do
        which "$i" &>/dev/null || { 
            # Try to install the package, update repos if first attempt fails
            sudo apt install -y "$i" &>/dev/null || { 
                sudo apt update -y &>/dev/null && sudo apt install -y "$i" &>/dev/null; 
            }
        }
    done

    # Check and install net-tools separately (contains netstat command)
    which netstat &>/dev/null || {
        sudo apt install -y net-tools &>/dev/null || {
            sudo apt update -y &>/dev/null && sudo apt install -y net-tools &>/dev/null
        }
    }
}

# Function: message
# Purpose: Check service status and interact with user for next actions
# Parameter: $1 - service name (node_exporter, prometheus, grafana)
# Returns: Calls appropriate functions based on service state and user choice

message(){
if  sudo systemctl status $1.service &>/dev/null ;then
        echo "The service $1 is up and running, do we need a reconfiguration ? [y/n]"
        read RESPONSE
        if [ "$RESPONSE" = "y" ]; then
                port $1 # Go to port configuration
        fi
# Check if service files exist but service is not running        
elif [ -f /etc/systemd/system/$1.service ];then
        echo "It looks like we have the files installed but the service isn't up and running: would you like to start/reconfigure/pass ? [s/r/p]"
        read RESPONSE
        if [ "$RESPONSE" = "s" ];then
                sudo systemctl start $1.service
        elif [ "$RESPONSE" = "r" ]; then
                port $1
        else
                echo "We can't work in these conditions, bye"
                exit # Exit if user chooses to pass
        fi
else
        # Service is not installed at all
        echo "We dont have the service $1 installed at all, would you like so ? [y/n]"
        read RESPONSE
        if [ "$RESPONSE" = "y" ];then
                install $1
        else
                echo "We can't work in these conditions, bye"
                exit # Exit if user chooses to pass
        fi
fi
}
# Function: install
# Purpose: Handle fresh installation of services including user creation and version selection
# Parameter: $1 - service name
# Dependencies: Requires version files (node_exporter, prometheus, grafana) with download URLs

install(){
# Create system user for the service if it doesn't exist
# -r: system user, -s /bin/false: no shell access
grep $1 /etc/passwd || sudo useradd -rs /bin/false $1 &>/dev/null
echo "Welcome to the service $1 installation, please choose the installation option the default is 1"
RESPONSE=1
# Display numbered list of available versions from version file
cat -n $1
read RESPONSE
# Download the selected version URL from the version file
# If selection fails, fallback to first line (latest/default version)
/usr/bin/wget $(cat $1 | head -$RESPONSE | tail -1) || /usr/bin/wget $(head -1 $1) 
tar xvf $1*.gz
port $1
}

# Function: port
# Purpose: Interactive port selection with validation and availability checking
# Parameter: $1 - service name (passed through to conf function)
# Validates: Port range (1025-65535), numeric input, port availability

port() {
    while true; do
        read -p "Please enter the port number you want to run your service on (between 1025 or 65535): "
        if ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
            echo "Error: Non-numeric prompt" 
            continue
        fi
        if [ "$REPLY" -lt 1025 ] || [ "$REPLY" -gt 65535 ]; then
            echo "Error: Please input a number in correct range " 
            continue
        else
            echo "Thank you! You entered $REPLY, checking the port availability..." 
            if sudo netstat -tulpn | grep ":$REPLY" &> /dev/null; then
                echo "The port is currently unavailable"
            else
                echo "Congrats!!! The port $REPLY is available for this service" 
                echo "$REPLY"
                break
            fi
        fi
    done
    conf $1 $REPLY
}
# Function: conf
# Purpose: Configure services with specific settings and create systemd service files
# Parameters: $1 - service name, $2 - selected port
# Creates: systemd service files, moves binaries, sets permissions

conf(){
    if [ "$1" = "prometheus" ]; then
        sudo mv $1-*64/* /usr/local/bin/ &> /dev/null || true
        sudo mkdir -p /var/lib/$1/data &>/dev/null || true
        sudo chown -R $1.$1 /var/lib/prometheus &>/dev/null || true
        sudo mv prometheus.yml /usr/local/bin/prometheus.yml &> /dev/null || true
        EXECSTART="/usr/local/bin/$1 --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data --web.listen-address=0.0.0.0:$2 --web.external-url=https://edgar.am/prometheus --web.route-prefix=/prometheus"
        
    elif [ "$1" = "grafana" ]; then
        sudo mkdir -p /usr/local/grafana &> /dev/null || true
        sudo mv grafana-v*/* /usr/local/grafana &> /dev/null || true
        sudo cp datasources.yaml /usr/local/grafana/conf/provisioning/datasources/ &>/dev/null || true
        sudo chown -R grafana:users /usr/local/grafana &>/dev/null || true
        EXECSTART="/usr/local/grafana/bin/grafana server --config=/usr/local/grafana/conf/defaults.ini  --homepath=/usr/local/grafana"
        sudo sed -i "s/3000/$2/g" /usr/local/grafana/conf/defaults.ini &>/dev/null || true
    else
        sudo mv $1-*64/* /usr/local/bin/ &> /dev/null || true
        EXECSTART="/usr/local/bin/$1 --web.listen-address=0.0.0.0:$2"
    fi

    echo " 
                [Unit]
                Description=$1
                After=network.target

                [Service]
                User=$1
                Group=$1
                Type=simple
                ExecStart=$EXECSTART

                [Install]
                WantedBy=multi-user.target
                " | sudo tee /etc/systemd/system/$1.service &>/dev/null || true

    sudo systemctl daemon-reload &>/dev/null || true
    sudo systemctl restart $1.service &>/dev/null || true
    sudo systemctl enable $1.service &>/dev/null || true
}

# Function: nginx_setup
# Purpose: Configure Nginx reverse proxy with SSL certificates and service routing
# Detects: Running service ports automatically
# Configures: SSL certificates, proxy rules, local DNS resolution

nginx_setup()
{
echo "Starting Nginx configuration......"
sleep 15        
PORT1=$(sudo netstat -ltnp | grep node_exporter | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
PORT2=$(sudo netstat -ltnp | grep prometheus | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
PORT3=$(sudo netstat -ltnp | grep grafana | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)


sed "s/PORT1/$PORT1/g; s/PORT2/$PORT2/g; s/PORT3/$PORT3/g;"  edgar.conf | sudo tee /etc/nginx/conf.d/edgar.conf &> /dev/null
sudo mkdir -p /etc/nginx/ssl &>/dev/null
sudo mv nginx* /etc/nginx/ssl &> /dev/null
sudo cp /etc/nginx/ssl/nginx-selfsigned.crt /usr/local/share/ca-certificates/nginx-selfsigned.crt &>/dev/null
sleep 20
sudo update-ca-certificates &>/dev/null
sudo systemctl restart grafana &>/dev/null
sleep 15
sudo nginx -t && sudo nginx -s reload
grep edgar.am /etc/hosts || echo "127.0.0.1 edgar.am" | sudo tee -a /etc/hosts &> /dev/null
}



start_checks
message node_exporter
message prometheus
message grafana
nginx_setup
echo "Clening ..."
rm -rf node_exporter-* grafana-* prometheus-* &>/dev/null
echo "Done !"