FROM alpine:edge

RUN  apk update
     apk add --no-cache --virtual .build-deps ca-certificates curl unzip nginx

COPY etc/ /conf
COPY wwwroot.tar.gz /usr/share/nginx/wwwroot/wwwroot.tar.gz
ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
