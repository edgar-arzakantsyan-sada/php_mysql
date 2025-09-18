FROM ubuntu
WORKDIR /app

RUN apt-get update && apt-get install -y wget 

RUN wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
RUN tar -xzf node_exporter-1.6.1.linux-amd64.tar.gz 
RUN mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/ 
RUN chmod +x /usr/local/bin/node_exporter 
RUN rm -rf node_exporter-1.6.1.linux-amd64*

EXPOSE 9100

CMD ["/usr/local/bin/node_exporter"]