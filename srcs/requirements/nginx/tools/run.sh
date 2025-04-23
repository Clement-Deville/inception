#!/bin/sh

PATH=/bin:/sbin:/usr/sbin:/usr/bin

# Function to read secret from file
read_secret() {
    local secret_file="$1"
    if [ -f "$secret_file" ] && [ -r "$secret_file" ]; then
        cat "$secret_file"
    else
        echo ""
    fi
}

# Set Authentification secrets variables
for var in AUTH_USER AUTH_PASSWORD; do
	eval exp_var="\$${var}"

	# Check secrets
	## If secrets is mounted, export secret that has been read
   	exp_secret="/run/secrets/$(echo $var | tr '[:upper:]' '[:lower:]')"

	if [ -z "$exp_var" ] && [ -f "$exp_secret" ]; then
        	eval "export ${var}=$(read_secret "$exp_secret")"
    	fi

	# Check _FILE
	## If specific file is specified, read secret from it
   	eval exp_file_var="\$${var}_FILE"

	if [ -z "$exp_var" ] && [ -n "$exp_file_var" ]; then
		eval "export ${var}=$(read_secret "$exp_file_var")"
   	fi
done

## Generating Authentification Password for goaccess

if ! [ -f /etc/nginx/auth/goaccess/.htpasswd ]; then
	echo "[i] Generating password"
	htpasswd -b -c /etc/nginx/auth/goaccess/.htpasswd "$AUTH_USER" "$AUTH_PASSWORD" 2>/dev/null
fi

## GENERATING nginx.conf from template

envsubst "\$DOMAIN_NAME"  < /etc/nginx/nginx.conf.template \
	> /etc/nginx/nginx.conf && chown nginx:nginx /etc/nginx/nginx.conf
#cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf \
#	&& chown nginx:nginx /etc/nginx/nginx.conf 

## Starts NGINX

echo "[i] Launching nginx.."

exec nginx -g "daemon off;"
