FROM alpine:3.21.2

RUN apk update \
	&& addgroup -S -g 1001 nginx \
	&& adduser -S -g 1001 -u 1001 nginx --no-create-home \
	&& mkdir -p /etc/nginx/auth/goaccess \
	&& apk add --no-cache nginx apache2-utils envsubst\
	&& rm -f /var/cache/apk/*

COPY --chown=nginx: ./conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=744 ./tools/run.sh /sbin/run.sh

EXPOSE 443

CMD /sbin/run.sh
