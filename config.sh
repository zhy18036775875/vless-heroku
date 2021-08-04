#!/bin/sh

# VLESS new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {
            "listen": "127.0.0.1",
            "port": 7200,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$ID",
                        "flow": "xtls-rprx-direct",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                   "path": "/$ID-vless?ed=2048"
                }
            },
            "listen": "127.0.0.1",
            "port": 7201,
            "protocol": "dokodemo-door",
            "settings": {
                "address": "v1.mux.cool",
                "network": "tcp,udp",
                "followRedirect": false
            },
            "streamSettings": {
                "network": "ws",
                "allowInsecure": false,
                "wsSettings": {
                   "path": "/$ID-vless"
                }
            },
            "sniffing": {
                "enabled": true,
                "destOverride": [
                    "http",
                    "tls"
                ]
            }
        }
    ],
    "outbounds": [ 
        {
            "protocol": "freedom"
        }
    ]
}
EOF

# Config Caddy
mkdir -p /etc/caddy/ /usr/share/caddy/ && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "/^#/d"\
    -e "1c :$PORT"\
    -e "s/\$ID/$ID/g"\
    -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g"\
    -e "$s"\
    /conf/Caddyfile > /etc/caddy/Caddyfile
    echo /etc/caddy/Caddyfile

# Run VLESS
tor & /usr/local/bin/xray -config /usr/local/etc/xray/config.json & caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
