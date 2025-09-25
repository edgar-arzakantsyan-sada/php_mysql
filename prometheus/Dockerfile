FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD https://github.com/prometheus/prometheus/releases/download/v3.5.0/prometheus-3.5.0.linux-amd64.tar.gz .

RUN tar xfv prometheus-3.5.0.linux-amd64.tar.gz

FROM ubuntu:22.04

RUN mkdir -p /var/lib/prometheus/data 

COPY --from=builder /extract/prometheus-3.5.0.linux-amd64/* /usr/local/bin/

WORKDIR /prometheus

EXPOSE 9100

ENTRYPOINT ["/usr/local/bin/prometheus", \
     "--config.file=/etc/prometheus/prometheus.yml", \
     "--web.external-url=https://edgar.am/prometheus/", \
     "--web.route-prefix=/prometheus",\
     "--storage.tsdb.path=/var/lib/prometheus/data", \
     "--web.console.libraries=/usr/local/bin/console_libraries", \
     "--web.console.templates=/usr/local/bin/consoles"]