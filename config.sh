#!/bin/sh

# VLESS new configuration
sed -e "/^#/d"\
    -e "s/\$ID/$ID/g"\
    -e "s/\$ID-vless/$ID-vless/g"\
    -e "$s"\
    /etc/config.json > /usr/local/etc/xray/config.json
    echo /usr/local/etc/xray/config.json
    cat /usr/local/etc/xray/config.json


# Config Caddy
mkdir -p /etc/caddy/ /usr/share/caddy/ && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
curl -OsL $CADDYIndexPage /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
sed -e "/^#/d"\
    -e "1c :$PORT"\
    -e "s/\$ID/$ID/g"\
    -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g"\
    -e "$s"\
    /etc/Caddyfile > /etc/caddy/Caddyfile
    echo /etc/caddy/Caddyfile
    cat /etc/caddy/Caddyfile

# Run VLESS
tor & /usr/local/bin/xray -config /usr/local/etc/xray/config.json & caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
