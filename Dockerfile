FROM alpine:edge
RUN apk update && \
    apk add --no-cache --virtual ca-certificates curl unzip caddy tor && \
    mkdir -p /etc/caddy/ /usr/share/caddy/ && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt && \
    curl -fssL $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/ && \
    curl -fssL $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$ID/$ID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $ID)/g" >/etc/caddy/Caddyfile

COPY config.sh /config.sh
COPY config.json /usr/local/etc/xray/config.json
RUN chmod +x /config.sh
CMD /config.sh
RUN apk del .build-deps
