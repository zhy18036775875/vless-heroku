#!/bin/sh

# Global variables
DIR_CONFIG="/etc/v2ray"
DIR_RUNTIME="/usr/local"
DIR_TMP="$(mktemp -d)"

# VLESS new configuration
install -d /usr/local/etc/v2ray/
cat > /usr/local/etc/v2ray/config.json << EOF
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {
            "listen": "/etc/caddy/vless",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$ID",
                        "level": 0,
                        "email": "love@v2fly.org"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
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
mkdir -p /etc/caddy/ /usr/share/caddy/

# Robot configure
cat > /usr/share/caddy/robots.txt << EOF
User-agent: *
Disallow: /
EOF

# Other configure
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "/^#/d" -e "1c :$PORT" -e "s/\$ID/$ID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" -e "$s" /conf/Caddyfile > /etc/caddy/Caddyfile
echo /etc/caddy/Caddyfile

# Run VLESS
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & /usr/local/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
