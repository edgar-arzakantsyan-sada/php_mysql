FROM prom/prometheus

COPY ./prometheus.yml /etc/prometheus/prometheus.yml

EXPOSE 9090

ENTRYPOINT [ "prometheus", \
             "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles", \
             "--web.external-url=http://localhost:9090", \
             "--log.level=info" ] 