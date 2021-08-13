#!/bin/sh

# VLESS new configuration
mkdir -p  /usr/local/bin
cd /usr/local/bin
wget "https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip"
unzip v2ray-linux-64.zip
rm -rf v2ray-linux-64.zip
chmod +x ./v2ray
chmod +x ./v2ctl
ls -al

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

# Config vless
sed -e "/^#/d"\
    -e "s/\$ID/$ID/g"\
    /conf/config.json >  /usr/local/bin/config.json
echo /usr/local/bin/config.json
cat /usr/local/bin/config.json

# Configure nginx
sed -e "/^#/d"\
    -e "s/\$PORT}/$PORT/g"\
    -e "s/\$ID/$ID/g"\
    -e "$s"\
    /conf/nginx.conf > /etc/nginx/conf.d/ray.conf
echo /etc/nginx/conf.d/ray.conf
cat /etc/nginx/conf.d/ray.conf

# Run VLESS
cd /usr/local/bin/
tor & ./v2ray -c ./config.json
rm -rf /etc/nginx/sites-enabled/default
nginx -g 'daemon off;'
