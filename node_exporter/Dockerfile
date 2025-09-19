FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz .

RUN tar -xzvf node_exporter-1.6.1.linux-amd64.tar.gz

FROM ubuntu:22.04

RUN useradd -u 987 -M -s /usr/sbin/nologin node_user

COPY --from=builder --chown=6534:6534 /extract/node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

WORKDIR /node_exporter

USER node_user

EXPOSE 9100

ENTRYPOINT ["/usr/local/bin/node_exporter"]
