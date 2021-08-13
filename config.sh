#!/bin/sh

# VLESS new configuration


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

# Configure nginx
sed -e "/^#/d"\
    -e "s/\${PORT}/${PORT}/g"\
    -e "s/\${ID}/${ID}/g"\
    -e "$s"\
    /conf/nginx.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf

# Run VLESS
tor & /usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json & rm -rf /etc/nginx/sites-enabled/default & nginx -g 'daemon off;'
