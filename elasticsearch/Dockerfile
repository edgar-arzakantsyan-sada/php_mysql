FROM ubuntu:24.04 AS builder

WORKDIR /extract
ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.1.4-linux-x86_64.tar.gz .
RUN tar xvf elasticsearch-9.1.4-linux-x86_64.tar.gz 

FROM ubuntu:22.04

RUN useradd -u 987 -M -s /usr/sbin/nologin elasticsearch
COPY --from=builder --chown=987:987 /extract/elasticsearch-9.1.4 /usr/share/elasticsearch

WORKDIR /usr/share/elasticsearch
USER elasticsearch

EXPOSE 9200 9300


ENTRYPOINT ["/usr/share/elasticsearch/bin/elasticsearch"]
