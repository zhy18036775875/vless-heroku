FROM ubuntu:latest

RUN sudo set -ex\
    && sudo apt-get update -y \
    && sudo apt-get upgrade -y \
    && sudo apt-get install -y wget unzip qrencode curl\
    && sudo apt-get install -y shadowsocks-libev\
    && sudo apt-get install -y nginx\
    && sudo apt autoremove -y
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
