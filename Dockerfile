FROM debian:sid

RUN set -ex && \
    apt update && \
    apt upgrade -y && \
    apt update && \
    apt install -y debian-keyring debian-archive-keyring apt-transport-https ca-certificates wget curl unzip tor && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | tee /etc/apt/trusted.gpg.d/caddy-stable.asc && \
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list &&\
    apt update && \
    apt install -y caddy
    mkdir /tmp/v2ray && \
    curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray && \
    install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray && \
    install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl && \
    v2ray -version

COPY etc/ /conf
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
