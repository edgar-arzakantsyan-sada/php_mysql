# **Prometheus & Node Exporter Setup** 🚀

This repository contains the configuration files and steps for setting up **Prometheus** and the **Node Exporter** as services on a Linux VM. The setup includes an **Nginx** reverse proxy to securely expose the services via HTTPS.

-----

## **Prerequisites**

Before you begin, ensure you have a virtual machine (VM) running a Debian-based operating system like Ubuntu. You'll need `root` or `sudo` access to install and configure the necessary software.

-----

## **Installation and Configuration Steps**

The following sections detail the steps taken to install and configure all the components.

### **1. Installing Nginx and Configuring as a Reverse Proxy**

Nginx is used as a reverse proxy to manage incoming traffic and provide a secure, HTTPS connection to the monitoring services. The following configuration redirects all HTTP traffic to HTTPS and routes requests to the appropriate services.

First, install Nginx:

```bash
apt install nginx -y
```

Next, configure Nginx. The provided configuration sets up an HTTPS listener on port `443` and a redirect for HTTP traffic on port `80`. The `/` location is proxied to Prometheus on `http://localhost:9090`, and the `/metrics` location is proxied to the Node Exporter on `http://localhost:9100`.

*Note: This configuration uses a self-signed SSL certificate, which is suitable for testing or internal use. For production environments, use a trusted certificate from a Certificate Authority (CA).*

```nginx
server {
    listen 80;
    server_name edgar.am;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name edgar.am;

    ssl_certificate /etc/nginx/ssl/nginx-selfsigned.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx-selfsigned.key;

    location /metrics {
        proxy_pass http://localhost:9100;
    }

    location / {
        proxy_pass http://localhost:9090;
    }
}
```

### **2. Creating the Node Exporter Service**

To run the Node Exporter as a system service, a dedicated, non-root user is created for security purposes. This ensures the service doesn't have unnecessary privileges.

Create a non-root user named `node_exporter`:

```bash
useradd -rs /bin/false node_exporter
```

Then, create the `systemd` service file at `/etc/systemd/system/node_exporter.service`. This file defines how the service should be run, including its description, user, and executable path.

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

| Parameter      | Description                                                                                             |
|----------------|---------------------------------------------------------------------------------------------------------|
| `Description`  | A human-readable name for the service.                                                                  |
| `After`        | Specifies that this service should start after the `network.target` has been reached.                   |
| `User`/`Group` | Defines the user and group under which the service will run.                                            |
| `Type`         | `simple` indicates that the process specified in `ExecStart` is the main process of the service.        |
| `ExecStart`    | The absolute path to the executable file for the service.                                               |
| `WantedBy`     | Specifies the target unit that this service should be enabled for. `multi-user.target` is for multi-user, non-graphical systems. |

Finally, start and enable the service to ensure it runs on boot:

```bash
systemctl start node_exporter.service
systemctl enable node_exporter.service
```

### **3. Creating the Prometheus Service**

Similar to the Node Exporter, a `systemd` service file is created for Prometheus. This ensures it runs reliably and can be managed with standard `systemd` commands.

The service file is located at `/etc/systemd/system/prometheus.service`:

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

Start and enable the Prometheus service:

```bash
systemctl start prometheus.service
systemctl enable prometheus.service
```

-----

## **Verification**

After starting all services, you can verify that they are running and listening on the correct ports.

Use `netstat` to check the listening ports:

```bash
netstat -tlpn
```

You should see output similar to this, showing that Prometheus is listening on port `9090` and the Node Exporter on `9100`. Nginx is listening on ports `80` and `443` and handling the traffic.

```text
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:443             0.0.0.0:* LISTEN      21300/nginx: master
tcp        0      0 0.0.0.0:80              0.0.0.0:* LISTEN      21300/nginx: master
tcp        0      0 :::9090                 :::* LISTEN      34330/prometheus
tcp        0      0 :::9100                 :::* LISTEN      1947/node_exporter
```

You can also use `ps aux` to confirm the processes are running under the correct users:

```text
node_ex+   34434  1.4  0.6 1239776 12368 ?       Ssl  09:36   0:00 /usr/local/bin/node_exporter
prometh+   34436  6.9  3.7 1338660 75324 ?       Ssl  09:36   0:00 /usr/local/bin/prometheus --config.file=/usr/local/bin/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/data
```

-----

## **Prometheus Configuration (`prometheus.yml`)**

The `prometheus.yml` file is the central configuration for Prometheus. The provided configuration includes two scrape jobs: one for **Prometheus itself** and another for the **Node Exporter**.

```yaml
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

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["34.47.28.41:9090"]
        # The label name is added as a label `label_name=<label_value>` to any timeseries scraped from this config.
        labels:
          app: "prometheus"

  - job_name: "node"
    static_configs:
      - targets: ["edgar.am:80"]
    metrics_path: "/metrics"
```

The configuration is straightforward:

  * The **`global`** section sets the default `scrape_interval` and `evaluation_interval` to 15 seconds.
  * The **`scrape_configs`** section defines two jobs:
      * **`prometheus`**: Scrapes metrics from the Prometheus server itself, using its IP and default port. A label `app: "prometheus"` is added to all metrics from this job.
      * **`node`**: Scrapes metrics from the Node Exporter. It uses the domain name `edgar.am` and port `80`, leveraging the Nginx reverse proxy to access the metrics endpoint at `/metrics`.
