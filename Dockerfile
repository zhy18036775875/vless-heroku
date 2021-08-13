FROM debian:sid

RUN set -ex\
    && apt update -y \
    && apt upgrade -y \
    && apt install -y wget unzip qrencode curl\
    && apt install -y shadowsocks-libev\
    && apt install -y nginx\
    && apt autoremove -y
    curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip && \
    unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray && \
    install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray && \
    install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl && \
    v2ray -version && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/v2ray

COPY etc/ /conf
COPY wwwroot.tar.gz /usr/share/nginx/wwwroot/wwwroot.tar.gz
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
