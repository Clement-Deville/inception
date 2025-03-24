#!/bin/sh
#exec sleep infinity
#exec goaccess /var/log/nginx/access.log -o /var/www/html/sample.com/report.html --real-time-html --log-format=COMBINED

if ! [ -d /var/www/html/sample.com/goaccess ]; then
	mkdir -p /var/www/html/sample.com/goaccess
fi

exec /usr/bin/goaccess -f /var/log/nginx/access.log \
          --real-time-html \
          -o /var/www/html/sample.com/goaccess/report.html --port=7890 \
          --config-file=/etc/goaccess/goaccess.conf --log-format=COMBINED \
	  --ws-url=wss://localhost.cdeville.42.fr:4443/goaccess/ws \
	  --origin=https://localhost.cdeville.42.fr:4443/goaccess
	
