#!/bin/bash

check_if_running(){

sudo systemctl status $1 &> /dev/null 

if [ $? -eq 0 ];then

        read -p  "The service $1 is up and running, do you want to reconfigure ? [y/n]"
        if [ "$REPLY" = "y" ]; then
                install $1
                VAR=0
        else
                echo "Alright, continuing !" >&2
                VAR=4
        fi
else
        ls -l /etc/systemd/system | grep -i $1 
        if [ $? -eq 0 ];then

                read -p "The service $1 is stopped, do you want to start it ? Press p if you want new port [y/n/p]" 
                if [ "$REPLY" = "y" ]; then
                        sudo systemctl start $1 
                        VAR=4         
                elif [ "$REPLY" = "p" ]; then
                        install $1 
                        VAR=0
                else
                        echo "There is nothing to do" >&2
                        VAR=5
                fi
        else
                read -p "You don't have the service $1 installed, do you want to install it ? [y/n]"
                if [ "$REPLY" = "y" ];then
                        install $1
                        VAR=0
                else
                        echo "There is nothing to do, bye" >&2
                        VAR=5
                fi
        fi
fi
}


install(){
name=$(echo "$1" | cut -d'.' -f1)
grep name /etc/passwd || sudo useradd -rs /bin/false $name &>/dev/null
if [ ! -f /etc/systemd/system/$1 ]; then
        if [ "$1" = "prometheus.service" ];then

                /usr/bin/wget wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
                tar xvf prometheus-3.5.0.linux-amd64.tar.gz
                sudo mkdir -p /var/lib/prometheus/data
                sudo chown -R prometheus.prometheus /var/lib/prometheus/
                sudo mv prometheus-3.5.0.linux-amd64/* /usr/local/bin/
        else
                /usr/bin/wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
                tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
                sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
        fi
        
fi
PORT=$(check_port)
if [ "$1" = "prometheus.service" ];then
        EXECSTART="/usr/local/bin/$name --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data --web.listen-address=0.0.0.0:$PORT"
else
        EXECSTART="/usr/local/bin/$name --web.listen-address=0.0.0.0:$PORT"
fi

                echo " 
                [Unit]
                Description=$name
                After=network.target

                [Service]
                User=$name
                Group=$name
                Type=simpe
                ExecStart=$EXECSTART


                [Install]
                WantedBy=multi-user.target
                " | sudo tee /etc/systemd/system/$1 &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart $1
sudo systemctl enable $1
}

check_port(){
                while true;
                do
                        read -p "Please enter the port number you want to run Node Exporter on (between 2000 or 65535)"
                        if ! [[ "$REPLY" =~ ^[0-9]+$ ]]; then
                                echo "Error: Non-numeric prompt" >&2
                                continue
                        fi
                        if [ $REPLY -lt 2000 ] || [ $REPLY -gt 65535 ]; then
                                echo "Error: Please input a number in correct range " >&2
                                continue
                        else
                                echo "Thank you! You entered $REPLY, checking the port availability..." >&2
                                sudo netstat -tulpn | grep ":$REPLY" &> /dev/null
                                if [ $? -ne 0 ]; then
                                        echo "Congrats!!! The port $REPLY is available for this service" >&2
                                        echo $REPLY
                                        break
                                else
                                        echo "The port is currently unavailable" >&2
                                fi
                        fi
                done
}
nginx_config(){
        REPLY=$(cat /etc/hosts | tail -1 | awk '{print $2}')
        if [ ! -f /var/log/nginx/access.log ];then
                sudo apt install nginx -y
                echo "Please enter your domain"
                read $REPLY
                sudo mkdir -p /etc/nginx/ssl
                echo "
                [req]
                distinguished_name = req_distinguished_name
                x509_extensions = v3_req
                prompt = no

                [req_distinguished_name]
                C = AM
                ST = Yerevan
                L = Yerevan
                O = Internet Widgits Pty Ltd
                CN = "$REPLY"
                emailAddress = edgararzakantsyan6@gmail.com

                [v3_req]
                subjectAltName = @alt_names

                [alt_names]
                DNS.1 = "$REPLY" " | sudo tee /etc/nginx/ssl/openssl-san.cnf &> /dev/null
                sudo openssl req -x509 -nodes -days 365   -newkey rsa:2048   -keyout /etc/nginx/ssl/nginx-selfsigned.key   -out /etc/nginx/ssl/nginx-selfsigned.crt   -config /etc/nginx/ssl/openssl-san.cnf
                ip=$(curl -s ifconfig.me)
                echo "$ip       $REPLY" | sudo tee -a /etc/hosts &>/dev/null
        fi

        PORT1=$(sudo netstat -ltnp | grep node_exporter | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
        PORT2=$(sudo netstat -ltnp | grep prometheus | awk '{print $4}' | awk -F':' '{print $NF}' | head -n1)
        echo "
server{
        listen 80;
        server_name $REPLY;
        return 301 https://\$host\$request_uri;
}
server{
        listen 443 ssl;
        server_name $REPLY;
        ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
        ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;
        location /node_exporter {
                proxy_pass http://localhost:$PORT1/;
        }
        location /node_exporter/metrics {
                proxy_pass http://localhost:$PORT1/metrics;
        }
        location / {
                proxy_pass http://localhost:$PORT2;
        }
}
" | sudo tee /etc/nginx/conf.d/prometheus.conf &>/dev/null
sudo systemctl restart nginx 
}

start_checks(){
for i in wget openssl tee curl; do
        which $i || sudo apt install $i || sudo apt update && sudo apt install $i &> /dev/null
        done
        which netstat || sudo apt install net-tools
}


#Main - Dzerov Grac a chmtaceq comment ka uremn AI a ))

start_checks
check_if_running node_exporter.service
if [ $VAR -eq 5 ];then
        echo "Node Exporter is not needed, we are not going to continue ))"
        exit 
fi
VAR1=$VAR
check_if_running prometheus.service
if [ $VAR -eq 5 ];then
        echo "Prometheus is not needed, we are not going to continue ))"
        exit 
fi
let VAR1+=VAR
if [ $VAR1 -eq 9 ];then
        echo "Prometheus is not needed, we are not going to continue ))"
        exit
fi
if [ $VAR1 -ne 8 ];then
        nginx_config
else
        echo "Nginx configuration stays the same, bye"
fi