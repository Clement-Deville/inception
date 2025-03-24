#!/bin/sh
DIR_PATH=/var/www/html/sample.com


if [ -d /wordpress_setup/sample.com ] && ! [ -d "$DIR_PATH" ]; then
	mv /wordpress_setup/sample.com "$DIR_PATH"
	curl https://downloads.wordpress.org/plugin/redis-cache.2.5.4.zip --output redis-cache.2.5.4.zip
	wp-cli plugin install redis-cache.2.5.4.zip –activate
	wp-cli redis enable
fi

chown -R www:www-data "$DIR_PATH" && chmod -R 755 "$DIR_PATH"

# start php-fpm
mkdir -p /usr/logs/php-fpm
exec php-fpm82 --nodaemonize
