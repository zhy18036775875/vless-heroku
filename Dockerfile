FROM alpine:edge
RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates curl unzip caddy tor
COPY config.sh /config.sh
COPY config.json /usr/local/etc/xray/config.json
RUN chmod +x /config.sh
CMD /config.sh
RUN apk del .build-deps
