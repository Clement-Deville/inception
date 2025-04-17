FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk update && apk upgrade && apk add --no-cache php82 php82-fpm \
	php82-mysqli php82-curl php82-dom php82-exif php82-fileinfo \
	php82-pecl-igbinary php82-pecl-imagick php82-intl php82-mbstring php82-openssl \
	php82-xml php82-zip php82-phar curl zip\
	&& rm -f /var/cache/apk/*

RUN curl https://fr.wordpress.org/latest-fr_FR.zip --output /latest-fr_FR.zip \
	&& unzip /latest-fr_FR.zip && rm /latest-fr_FR.zip && mkdir /wordpress_setup\
	&& mv /wordpress /wordpress_setup/sample.com && ln -s /usr/bin/php82 /usr/bin/php

COPY --chown=:www-data ./conf/* /wordpress_setup/sample.com/
COPY --chown=:www-data ./tools/run.sh /wordpress_setup/run.sh
COPY --chown=:www-data ./tools/pre-run.sh /wordpress_setup/pre-run.sh

RUN adduser -G www-data www 2> /debug || echo lol && chmod +x /wordpress_setup/*.sh && /wordpress_setup/pre-run.sh\
&& addgroup -S -g 1001 nginx && adduser -S -g 1001 -u 1001 --no-create-home nginx \
	&& curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp-cli \
	&& chown :www-data /usr/bin/wp-cli \
	&& mkdir -p /usr/logs/php-fpm \
	&& chown -R www:www-data "/usr/logs/php-fpm" && chmod -R 755 "/usr/logs/php-fpm" \
	&& mkdir -p /var/www/html && chown www:www-data /var/www/html \
	&& chown -R www:www-data /var/log/php82

RUN apk add mariadb-client

EXPOSE 9000

#USER www

CMD ["/wordpress_setup/run.sh", "daemon off"]
