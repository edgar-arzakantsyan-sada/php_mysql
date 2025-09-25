FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD  https://github.com/grafana/loki/releases/download/v3.4.6/loki-linux-amd64.zip .

RUN apt update && apt install unzip && unzip loki-linux-amd64.zip

FROM ubuntu:22.04 

RUN useradd -u 987 -M -s /usr/sbin/nologin loki_user && mkdir -p /etc/loki && chown -R 987:987 /etc/loki

COPY --from=builder --chown=987:987 /extract/loki-linux-amd64 /usr/local/bin

USER loki_user

EXPOSE 3100

ENTRYPOINT ["/usr/local/bin/loki-linux-amd64"]