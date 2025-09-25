FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD  https://github.com/grafana/loki/releases/download/v3.4.6/promtail-linux-amd64.zip .

RUN apt update && apt install unzip && unzip promtail-linux-amd64.zip

FROM ubuntu:22.04 

RUN useradd -u 987 -M -s /usr/sbin/nologin promtail_user && mkdir -p /etc/promtail && chown -R 987:987 /etc/promtail

COPY --from=builder --chown=987:987 /extract/promtail-linux-amd64 /usr/local/bin

USER promtail_user

EXPOSE 9080

ENTRYPOINT ["/usr/local/bin/promtail-linux-amd64"]
