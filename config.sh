#!/bin/sh

# Set iptables
iptables -A INPUT -p tcp --tcp-flags RST ACK -j DROP
iptables -A OUTPUT -p tcp --tcp-flags RST ACK -j DROP
iptables -t nat -A PREROUTING -p tcp --tcp-flags RST ACK -j DROP

# Install VLESS binary and decompress binary
mkdir /tmp/v2ray
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip -o /tmp/v2ray/v2ray.zip
busybox unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl
v2ray -version
rm -rf /tmp/v2ray

# Install geoip
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL raw.githubusercontent.com/Loyalsoldier/geoip/release/cn.dat -o /usr/local/bin/cn.dat

# VLESS new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "listen": "/etc/caddy/vless",
            "protocol": "vless",
            "sniffing": {
                "enabled": true,
                "destOverride": ["http","tls"]
            },
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
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-vless"
                }
            }
        }
    ],
    "routing": {
        "domainStrategy": "IPIfNonMatch",
        "domainMatcher": "mph",
        "rules": [
           {
              "type": "field",
              "protocol": [
                 "bittorrent"
              ],
              "ip": [
                  "ext:cn.dat:cn"
              ],
              "inboundTag": "cn",
              "outboundTag": "cn"
           }
        ]
    },
    "outbounds": [
        {
            "protocol": "freedom"
        },
        {
            "tag": "cn",
            "protocol": "blackhole"
        }
    ],
    "dns": {
        "servers": [
            "https://dns.google/dns-query",
            "https://cloudflare-dns.com/dns-query"
        ]
    }
}
EOF

# Run VLESS
/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json
