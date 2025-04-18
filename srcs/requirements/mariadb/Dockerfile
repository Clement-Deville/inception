FROM alpine:3.21.2

USER root

COPY ./tools/run.sh /

RUN apk add --no-cache \
    	ca-certificates \
	&& apk update && apk add --no-cache mariadb mariadb-server-utils && \
	rm -f /var/cache/apk/*

RUN mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /var/lib/mysql \
	&& mkdir /docker-entrypoint-initdb.d \
	&& chmod +x /init.sql /run.sh && mv /init.sql /docker-entrypoint-initdb.d/init.sql \
	&& mv /run.sh /docker-entrypoint-initdb.d/run.sh

EXPOSE 3306

CMD ["/docker-entrypoint-initdb.d/run.sh"]
