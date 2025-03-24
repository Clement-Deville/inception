FROM alpine:3.21.2
USER root
RUN apk update && addgroup -S -g 1001 nginx && adduser -S -g 1001 -u 1001 nginx --no-create-home && apk add --no-cache nginx && mkdir /etc/nginx/ssl \
	&& apk add openssl --no-cache && openssl req -x509 -nodes \ 
	-days 365 -newkey rsa:4096 -keyout /etc/nginx/ssl/localhost.key \ 
	-out /etc/nginx/ssl/localhost.crt -subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX" \
	&& rm -f /var/cache/apk/*

RUN mkdir -p /etc/nginx/sites-enabled/

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"] 
