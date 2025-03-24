#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin
if [ ! -d "/var/hugo/quickstart" ] 
then
	mkdir -p /var/hugo
	hugo new site /var/hugo/quickstart --format yaml
	cd /var/hugo/quickstart
	git init
	git clone https://github.com/adityatelange/hugo-PaperMod themes/PaperMod --depth=1
	echo "theme PaperMod" >> /var/hugo/quickstart/hugo.yaml
else
	cd /var/hugo/quickstart
fi
(cd themes/PaperMod && git pull)
IP=$(hostname -i | awk '{print $1}')
exec hugo server --bind 0.0.0.0 --baseURL http://$IP/
