cd /node_exporter
docker build -t node_image .

cd ../prometheus
docker build -t prometheus_image .

cd ../garafana
docker build -t grafana_image .

docker pull nginx

cd ..

docker network create my-network 




docker run -d -p 9100:9100 --name node_exporter_instance --network my-network node_image:latest 
docker run --name prometheus_instance --network my-network -d -p 9090:9090   --mount type=bind,src=./prometheus.yml,dst=/etc/prometheus/prometheus.yml  --mount source=my-vol,target=/var/lib/prometheus/data prometheus_image:latest
docker run -d -p 3000:3000 --name grafana_instance --mount type=bind,src=./datasources.yaml,dst=/usr/local/grafana/conf/provisioning/datasources/datasources.yaml grafana_image:latest 
docker run --name proxy --network my-network -d -p 80:80 -p 443:443 --mount type=bind,src=./edgar.conf,dst=/etc/nginx/conf.d/edgar.conf --mount type=bind,src=./nginx-selfsigned.crt,dst=/etc/nginx/ssl/nginx-selfsigned.crt --mount type=bind,src=./nginx-selfsigned.key,dst=/etc/nginx/ssl/nginx-selfsigned.key nginx


