FROM debian:buster-slim

RUN apt-get update && apt-get install -y \
    varnish \
    netcat

COPY default.vcl /etc/varnish/default.vcl
COPY run.sh /tmp/run.sh

CMD ["bash", "/tmp/run.sh"]