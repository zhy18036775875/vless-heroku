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

# Decompress webroot
cd /usr/share/nginx/wwwroot/
tar -zxvf wwwroot.tar.gz
rm -rf wwwroot.tar.gz

# Configure proxysite
if [[ -z "${ProxySite}" ]]; then
  s="s/proxy_pass/#proxy_pass/g"
  echo "site:use local wwwroot html"
else
  s="s|\${ProxySite}|${ProxySite}|g"
  echo "site: ${ProxySite}"
fi

sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s/\${ID}/${ID}/g"\
    -e "$s"\
    /conf/nginx.template.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf

# Run VLESS
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & rm -rf /etc/nginx/sites-enabled/default & nginx -g 'daemon off;'
