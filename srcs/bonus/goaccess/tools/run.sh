#!/bin/sh

if ! [ -d /var/www/html/sample.com/goaccess ]; then
	mkdir -p /var/www/html/sample.com/goaccess
fi

if ! [ -f /var/log/nginx/access.log ]; then
	touch /var/log/nginx/access.log
	chown 1001:1001 /var/log/nginx/access.log
fi

exec /usr/bin/goaccess -f /var/log/nginx/access.log \
          --real-time-html \
          -o /var/www/html/sample.com/goaccess/report.html --port=7890 \
          --config-file=/etc/goaccess/goaccess.conf --log-format=COMBINED \
	  --ws-url=wss://"$CUSTOM_URL"/goaccess/ws

