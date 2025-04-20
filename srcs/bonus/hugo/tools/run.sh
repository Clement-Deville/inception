#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [ ! -d "/var/hugo/quickstart" ]
then
	hugo new site /var/hugo/quickstart --format yaml
	cd /var/hugo/quickstart
	git init
	git submodule add -b main https://github.com/nunocoracao/blowfish.git themes/blowfish
	mv /hugo.yaml /var/hugo/quickstart/hugo.yaml
else
	echo "[i] Looking for updates.."
	cd /var/hugo/quickstart
	hugo mod get -u
	(cd themes/blowfish && git pull)
fi

IP=$(hostname -i | awk '{print $1}')
exec hugo server --bind 0.0.0.0 --baseURL http://$IP/
