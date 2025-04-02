FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk -U upgrade && apk add --no-cache goaccess \
	&& rm -f /var/cache/apk/*

USER root

RUN mkdir -p /var/www/html

COPY --chown=:www-data ./tools/run.sh /setup/run.sh

EXPOSE 7890

CMD ["/setup/run.sh", "daemon off"]
