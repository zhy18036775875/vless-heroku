FROM alpine:edge

RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates curl unzip caddy tor && \
    mkdir -p /tmp/xray && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray/xray.zip -d /tmp/xray && \
    install -m 755 /tmp/xray/xray /usr/local/bin/xray && \
    xray -version && \
    rm -rf /tmp/xray && \
    rm -rf /var/cache/apk/*
RUN apk del .build-deps
COPY etc/ /conf
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
