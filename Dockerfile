FROM alpine:edge

RUN apk update && \
    apk add --no-cache --virtual .build-deps ca-certificates nss-tools curl unzip tar tor && \
    mkdir /tmp/v2ray && \
    mkdir /tmp/caddy && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray && \
    install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray && \
    install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl && \
    v2ray -version && \
    rm -rf /var/cache/apk/* && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/caddy/caddy.tar.gz https://github.com/caddyserver/caddy/releases/download/v2.3.0/caddy_2.3.0_linux_amd64.tar.gz && \
    tar -zxvf /tmp/caddy/caddy.tar.gz -C /tmp/caddy && \
    install -m 755 /tmp/caddy/caddy /usr/local/bin/caddy && \
    caddy version && \
    rm -rf /tmp/v2ray && \
    rm -rf /tmp/caddy

RUN apk del .build-deps
COPY etc/ /conf
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
