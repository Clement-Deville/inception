#!/bin/sh

if ! [ -d /var/www/html/sample.com/adminer ] ; then
	mkdir /var/www/html/sample.com/adminer \
		&& mv /setup/* /var/www/html/sample.com/adminer \
		&& mv /var/www/html/sample.com/adminer/*.sh /setup/
fi

chown -R :www-data /var/www/html && chmod -R 755 /var/www/html

# start php-fpm

mkdir -p /usr/logs/php-fpm

exec php-fpm82 --nodaemonize
