FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD https://dl.grafana.com/oss/release/grafana-12.1.0.linux-amd64.tar.gz .
RUN tar xvf grafana-12.1.0.linux-amd64.tar.gz

FROM ubuntu:22.04

RUN mkdir -p /usr/local/grafana 
COPY --from=builder /extract/grafana-v12.1.0 /usr/local/grafana/

EXPOSE 3000

ENTRYPOINT ["/usr/local/grafana/bin/grafana", "server", "--config=/usr/local/grafana/conf/defaults.ini", "--homepath=/usr/local/grafana"]