FROM alpine

LABEL maintainer Nick Byrne <nick@morselabs.net>

ENV OPENFIRE_VERSION=4_7_5

RUN set -ex \
 && apk --no-cache add \
      bash \
      ca-certificates \
      curl \
      openjdk11 \
 && mkdir -p /opt \
 && curl -sSfL "https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_${OPENFIRE_VERSION}.tar.gz" | \
      tar -xz -C /opt \
 && curl -sSfLo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 \
 && chmod +x /usr/local/bin/dumb-init

ADD start.sh /usr/local/bin/start.sh

EXPOSE 9090 9091 5222 5223 5269
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/start.sh"]

