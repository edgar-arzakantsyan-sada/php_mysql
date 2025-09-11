#!/bin/bash


start_checks(){
    echo "Checking and installing necessary commans if needed...."
    for i in wget openssl tee curl nginx; do
        which "$i" >/dev/null &>/dev/null || { 
            sudo apt install -y "$i" &>/dev/null || { 
                sudo apt update -y &>/dev/null && sudo apt install -y "$i" >/dev/null &>/dev/null; 
            }
        }
    done

    which netstat >/dev/null &>/dev/null || {
        sudo apt install -y net-tools >/dev/null &>/dev/null || {
            sudo apt update -y >/dev/null &>/dev/null && sudo apt install -y net-tools >/dev/null &>/dev/null
        }
    }
}

message(){
sudo systemctl status $1.service &>/dev/null
if [ $? -eq 0 ];then
        echo "The service $1 is up and running, do we need a reconfiguration ? [y/n]"
        read RESPONSE
        if [ "$RESPONSE" = "y" ]; then
                port $1
        else
                return 
        fi
elif [ -f /etc/systemd/system/$1.service ];then
        echo "It looks like we have the files installed but the service isn't up and running: would you like to start/reconfigure/pass ? [s/r/p]"
        read RESPONSE
        if [ "$RESPONSE" = "s" ];then
                sudo systemctl start $1.service
                return
        elif [ "$RESPONSE" = "r" ]; then
                port $1
        else
                echo "We can't work in these conditions, bye"
                exit
        fi
else
        echo "We dont have the service $1 installed at all, would you like so ? [y/n]"
        read RESPONSE
        if [ "$RESPONSE" = "y" ];then
                install $1
        else
                echo "We can't work in these conditions, bye"
                exit
        fi
fi
}
install(){
grep $1 /etc/passwd || sudo useradd -rs /bin/false $1 &>/dev/null
echo "Welcome to the service $1 installation, please choose the installation option the default is 1"
RESPONSE=1
cat -n $1
read RESPONSE
/usr/bin/wget $(cat $1 | head -$RESPONSE | tail -1) || /usr/bin/wget $(head -1 $1) 
tar xvf $1*.gz
port $1
}

port() {

                while true;
                do
                        read -p "Please enter the port number you want to run your sercie on (between 2000 or 65535)"
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
conf $1 $REPLY
}

conf(){

echo "$1 is in under $2 port"
if [ "$1" = "prometheus" ];then
        sudo mv $1-*64/* /usr/local/bin/ &> /dev/null
        sudo mkdir -p /var/lib/$1/data
        sudo chown -R $1.$1 /var/lib/prometheus
        sudo mv prometheus.yml /usr/local/bin/prometheus.yml &> /dev/null
        EXECSTART="/usr/local/bin/$1 --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data --web.listen-address=0.0.0.0:$2 --web.external-url=https://edgar.am/prometheus --web.route-prefix=/prometheus"
        
elif [ "$1" = "grafana" ];then
        sudo mkdir -p /usr/local/grafana &> /dev/null
        sudo mv grafana-v*/* /usr/local/grafana &> /dev/null
        sudo cp datasources.yaml /usr/local/grafana/conf/provisioning/datasources/
        sudo chown -R grafana:users /usr/local/grafana
        EXECSTART="/usr/local/grafana/bin/grafana server --config=/usr/local/grafana/conf/defaults.ini  --homepath=/usr/local/grafana"
        sudo sed -i "s/3000/$2/g" /usr/local/grafana/conf/defaults.ini
else
        sudo mv $1-*64/* /usr/local/bin/ &> /dev/null
        EXECSTART="/usr/local/bin/$1 --web.listen-address=0.0.0.0:$2"
fi
echo " 
                [Unit]
                Description=$1
                After=network.target

                [Service]
                User=$1
                Group=$1
                Type=simpe
                ExecStart=$EXECSTART


                [Install]
                WantedBy=multi-user.target
                " | sudo tee /etc/systemd/system/$1.service &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart $1.service
sudo systemctl enable $1.service
}
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
sudo cp /etc/nginx/ssl/nginx-selfsigned.crt /usr/local/share/ca-certificates/nginx-selfsigned.crt
sudo update-ca-certificates
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
