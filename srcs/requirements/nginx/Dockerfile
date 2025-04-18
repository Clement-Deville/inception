FROM alpine:3.21.2

USER root

RUN apk update && addgroup -S -g 1001 nginx && adduser -S -g 1001 -u 1001 nginx --no-create-home && apk add --no-cache nginx \
	&& rm -f /var/cache/apk/*

COPY --chown=nginx: ./conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/sites-enabled/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
