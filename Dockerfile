FROM alpine:edge

RUN  apk update && \
     apk add --no-cache --virtual .build-deps ca-certificates curl unzip && \
     apk del .build-deps && \
     rm -rf /var/cache/apk/*

ADD config.sh /config.sh
RUN chmod +x /config.sh
CMD /config.sh
