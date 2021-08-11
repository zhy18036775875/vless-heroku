#!/bin/sh

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
                "security": "tls",
                "wsSettings": {
                   "path": "/$ID-vless"
                },
                "tlsSettings": {
                   "certificates": [
                       "certificateFile": "/usr/local/etc/v2cert/v2ray_cert.pem",
                       "keyFile": "/usr/local/etc/v2cert/v2ray_key.pem",
                   ],
                   "allowInsecure": false
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

# V2ctl cert configure
mkdir -p /usr/local/etc/v2cert
/usr/local/bin/v2ray/v2ctl cert -ca -domain="localhost" -expire=17532h -file=v2ray

# Other configure
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "/^#/d" -e "1c :$PORT" -e "s/\$ID/$ID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" -e "$s" /conf/Caddyfile > /etc/caddy/Caddyfile
echo /etc/caddy/Caddyfile

# Run VLESS
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
