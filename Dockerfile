FROM alpine:edge
RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates wget curl unzip caddy tor
COPY config.json /usr/local/etc/xray/config.json
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
RUN apk del .build-deps
