#!/bin/bash


echo "Installing and configuring Nginx ....."
apt update && apt install nginx -y &&
echo '
server{
        listen 80;
        server_name edgar.am;
        return 301 https://$host$request_uri;
}
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
'  > /etc/nginx/conf.d/prometheus.conf && mkdir /etc/nginx/ssl 
echo '
-----BEGIN CERTIFICATE-----
MIID7jCCAtagAwIBAgIUTXW8zHtKtuyppo0cQigYIL1xTxgwDQYJKoZIhvcNAQEL
BQAwgZQxCzAJBgNVBAYTAkFNMRAwDgYDVQQIDAdZZXJldmFuMRAwDgYDVQQHDAdZ
ZXJldmFuMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQxETAPBgNV
BAMMCGVkZ2FyLmFtMSswKQYJKoZIhvcNAQkBFhxlZGdhcmFyemFrYW50c3lhbjZA
Z21haWwuY29tMB4XDTI1MDgyMDA4NTQwMloXDTI2MDgyMDA4NTQwMlowgZQxCzAJ
BgNVBAYTAkFNMRAwDgYDVQQIDAdZZXJldmFuMRAwDgYDVQQHDAdZZXJldmFuMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQxETAPBgNVBAMMCGVkZ2Fy
LmFtMSswKQYJKoZIhvcNAQkBFhxlZGdhcmFyemFrYW50c3lhbjZAZ21haWwuY29t
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiS7HgiL2/JVw/w0WXo+i
+rHY3gEtUUnGWH4VWAe+JBbSjMpalP2hXVd7+4ZeA7/I+yD9Guxov7/8GVD4ryLh
+JyfI7IWtHwIMFM92t7g4yyuU8JjTav1Scs0EFOWYdQRtBMoiX4uHiOzkW+47drq
Bl/j9hdI2x/uUv6+FcPK2Vuou467YMapRlgCSGHlSry4MfQ4DUiDsGZlA4Rack1G
ifCHeV3ScBreydBmxl0mgNBaXMyGDR7b6rbMfNL4ELsipoyV/fYtjCHUss16tF2q
s6kir1iCYVc3SG8LXqKLrD6K3gt56K+R65nVSz3l9uPPsAFbAgrKvNpax3Ymw7yr
ZQIDAQABozYwNDATBgNVHREEDDAKgghlZGdhci5hbTAdBgNVHQ4EFgQUdaqboqLF
/Go+keq+eP4ekFsiYpIwDQYJKoZIhvcNAQELBQADggEBACImTF/2iON92LVim+jN
suUSAa5l3d+luHXdGcahxKeY5xaMO7SXIbQj8PA6uV7LNXB2za9nuHOjd/g1yTNF
fNjVYUVK2SHiXvl0VlZuJtbxCwu8AEuPQWHiySDpRvdCxdEXhaext4u62pfof2RZ
R8VGJ6YZ/ZPQ6RCrXV+J976hzPfAcyHsyqUs+zPN/+XMbptEusH3JhqjplotwLGJ
t3gtWLHhNAD8iMex+FrhZZLPpSrf2+XnASow7BUbqSpTGf/YxNJw1sCmeW2QGIVo
q2n1Nfu22XdGgJZyVQ5ML7HydhnTOKD6wMX2UKILkVapYgLSwdwVIxNUhlD3H2HW
bC0=
-----END CERTIFICATE-----
' > /etc/nginx/ssl/nginx-selfsigned.crt
echo '
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCJLseCIvb8lXD/
DRZej6L6sdjeAS1RScZYfhVYB74kFtKMylqU/aFdV3v7hl4Dv8j7IP0a7Gi/v/wZ
UPivIuH4nJ8jsha0fAgwUz3a3uDjLK5TwmNNq/VJyzQQU5Zh1BG0EyiJfi4eI7OR
b7jt2uoGX+P2F0jbH+5S/r4Vw8rZW6i7jrtgxqlGWAJIYeVKvLgx9DgNSIOwZmUD
hFpyTUaJ8Id5XdJwGt7J0GbGXSaA0FpczIYNHtvqtsx80vgQuyKmjJX99i2MIdSy
zXq0XaqzqSKvWIJhVzdIbwteoousPoreC3nor5HrmdVLPeX248+wAVsCCsq82lrH
dibDvKtlAgMBAAECggEABOtoy7Wxyk6Yqgjf3b3EcD2bA6EirSjaZFeHL+w9KSGp
ZNOn6nJrDEQkJdnEetlwnXLqKMJEImZB5e2FsZAsbuQ8/8R19HyDNapyjCwUgAkc
6lONCJ7LUd1n7VL2EGWQyfaq7D1abYnFuYg6Z0tDu71KGUvt+K+9Nfw9OF4YYvGN
WWHYOYbXOx1eR18GK44YjaAldDcA7B4cupdCPy9VYHdydahY+2mW/R9TGcY9YvUh
z/i5VThOMTRRu9BGnxiQicVn3hjMAtA+bS+KkR/FTcYY4Z90jVLm6yIv1o6KKvdg
CYbHVF8Ev5K68xBXoOQZBdyq7kSQMRsnEWcvWkLX4QKBgQDB3ZAB6UBgpNcuVKS8
Gtw12XWNg+9MbSxdI3NwMs8eI6ZHtzncjW5bKm57aDWdwGZWKdobBumVsqoxQf1m
nPGk+7YMfcek3PwQkBgfOWwrgrLqIzqp125/oPV/uyqLcgZfmXJGGHOLDiKeY6W9
ZXwzfU6PmGpEgHIx4RAeoslhBQKBgQC1JnaVlxsE92EkecrFnw9ctyDmka+T/6mW
FNdkr3Vh9fQZBjZMj6NnCLSmiz1GO05m35akpsZtBbKWQmBRZDDKjwqIkxbpq2Ob
8ziHjKlJpmSuRVVZ4iuSGTwrZ4TiTLteSFljZasW8t8nPfCVk3oVDeNsvKfMqhxi
PiMR2ymu4QKBgGojzRlOxEFlXq5uBzc5mYEeCv8s0dJNH3Hq2+P83WrJ59rx1QsM
n/Pn2k9Uca5pzV21UkVj1nVwOT/4uiz5Fk/WxAg4wRphJtxGl/5YaQG1cBFCsnaU
jVnxHRgOuC9agWTL1UXNU005svh25CI6svJZ065Iqz3P+TWX3ER5qbmlAoGAS0Ql
9VWJVnDqnds00xOZsG4ub16M0zNg5QjXze/RF9i3iUY5fWoY/JBzbtdfqDSwCLJR
xyu8OkQpxaDioC6+zwrL15813/TkOEHAdSGOnRlTr80C/4unitaNV4N1hQlYuH3b
Fh+CDNDwwz9LHPrfuKvCmMVx+umbTX5/18V19kECgYBwZHLx0+WVof8NdeYmgO3E
75CTOg/O4jbJyqsIkTjSs+G8rb+6+APc2PUTEZlyRtTSOUeW1XRwdaF+VS71HPbn
s3A97mftsdOYaCMOAwunF22qyfRsZUsWaYS3SCl+6+7tCzk1btbJFpK+OkqyJlHi
OaqAB5ByQB2RJh9dBWloiA==
-----END PRIVATE KEY-----
' > /etc/nginx/ssl/nginx-selfsigned.key && cp /etc/nginx/ssl/nginx-selfsigned.crt /usr/local/share/ca-certificates/edgar.am.crt && update-ca-certificates  && nginx -t && nginx -s reload && echo "Done !"

echo "Installing Node Exporter for future Prometheus Integration ... "

/usr/bin/wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
echo "Installed ! "

echo "Creating a system user called node_exporter ..."
/usr/sbin/useradd -rs /bin/false node_exporter
echo "Done !"

echo "Creating the systemd file for Node Exporter and enabling the service ..."

echo '
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
' > /etc/systemd/system/node_exporter.service && systemctl daemon-reload && systemctl start node_exporter.service && systemctl enable node_exporter.service && echo "Done !"

echo "Now working on Prometheus with the same steps "

echo "Creating a system user called prometheus ... "
/usr/sbin/useradd -rs /bin/false prometheus
echo "Done !"

mkdir -p /var/lib/prometheus/data
chown -R prometheus.prometheus /var/lib/prometheus/

/usr/bin/wget wget https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz
tar xvf prometheus-3.5.0.linux-amd64.tar.gz

echo '
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
' > /etc/systemd/system/prometheus.service 

mv prometheus-3.5.0.linux-amd64/* /usr/local/bin/

echo '
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
        #  - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    scheme: https
    tls_config:
      insecure_skip_verify: true 
    static_configs:
      - targets: ["edgar.am:80"]
       # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "prometheus"

  - job_name: "node"
    scheme: https
    tls_config:
      insecure_skip_verify: true
    static_configs:
      - targets: ["edgar.am:80"]
    metrics_path: "/node_exporter/metrics"
' > /usr/local/bin/prometheus.yml && echo "Starting Prometheus Service" && systemctl daemon-reload && systemctl start prometheus.service && systemctl enable prometheus.service && echo "Done !"
echo "Cleaning non necessary files ...." && rm -rf /home/edgararzakantsyan6/node* /home/edgararzakantsyan6/prome* && echo "Done !"
