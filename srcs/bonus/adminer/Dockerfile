FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk -U upgrade && apk add --no-cache php82 php82-fpm \
	php82-mysqli php82-common php82-curl php82-dom php82-exif php82-fileinfo php82-cli php-gd \
	php82-pecl-igbinary php82-pecl-imagick php82-intl php82-mbstring php82-openssl \
	php82-xml php82-zip php82-session curl zip\
	&& rm -f /var/cache/apk/*

USER root

COPY --chown=:www-data ./tools/run.sh /setup/run.sh
COPY --chown=:www-data ./tools/pre-run.sh /setup/pre-run.sh

RUN adduser -G www-data www || echo 1 \
	&& (cd /setup && wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php && chown :www-data /setup/*.php ) \
	&& chmod +x /setup/*.sh && /setup/pre-run.sh

EXPOSE 9000

CMD ["/setup/run.sh", "daemon off"]
