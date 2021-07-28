FROM alpine:edge
RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates curl unzip caddy tor

ADD config.json /usr/local/etc/xray/config.json
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
RUN apk del .build-deps
