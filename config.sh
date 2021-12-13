#!/bin/sh

# Get V2/X2 binary and decompress binary
mkdir /tmp/xray
curl --retry 10 --retry-max-time 60 -L -H "Cache-Control: no-cache" -fsSL github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip -o /tmp/xray/xray.zip
busybox unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray
install -m 755 /tmp/xray/geosite.dat /usr/local/bin/geosite.dat
install -m 755 /tmp/xray/geoip.dat /usr/local/bin/geoip.dat
xray -version
rm -rf /tmp/xray

# V2/X2 new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
    "log": {
        "loglevel": "none"
    },
    "inbounds": [
        {   
            "port": ${PORT},
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
                "allowInsecure": false,
                "wsSettings": {
                  "path": "/$ID-vless"
                }
            }
        },
        {   
            "port": ${PORT},
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password":"$ID",
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
                  "path": "/$ID-trojan"
                }
            }
        },
        {
            "listen": "127.0.0.1",
            "port": 8820,
            "tag": "onetag",
            "protocol": "dokodemo-door",
            "settings": {
                "address": "v1.mux.cool",
                "network": "tcp,udp",
                "followRedirect": false
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                   "path": "/$ID-ss"
                }
            }
        },
        {
            "listen": "127.0.0.1",
            "port": 8830,
            "protocol": "shadowsocks",
            "settings": {
                "email": "love@v2fly.org",
                "network": "tcp,udp",
                "method": "chacha20-ietf-poly1305",
                "password": "$ID",
                "level": 0,
                "ivCheck": true
            },
            "streamSettings": {
                "network": "domainsocket",
                "security": "none",
                "dsSettings": {
                  "path": "apath",
                  "abstract": true
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
              "domains": [
                  "geosite:cn",
                  "geosite:category-ads-all"
              ],
              "outboundTag": "blocked"
           },
           {
              "type": "field",
              "inboundTag": [
                  "onetag"
              ],
              "outboundTag":
                  "twotag"
           }
        ]
    },
    "outbounds": [
        {
            "protocol": "freedom"
        },
        {
            "protocol": "blackhole",
            "tag": "blocked"
        },
        {
            "protocol": "freedom",
            "tag": "twotag",
            "streamSettings": {
                "network": "domainsocket",
                "dsSettings": {
                    "path": "apath",
                    "abstract": true
                }
            }
        }
    ]
}
EOF

# Run V2/X2
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
