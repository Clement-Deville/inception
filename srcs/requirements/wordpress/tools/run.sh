#!/bin/sh
DIR_PATH=/var/www/html/sample.com

### HANDLING WP SECRETS

# Function to read secret from file
read_secret() {
    local secret_file="$1"
    if [ -f "$secret_file" ] && [ -r "$secret_file" ]; then
        cat "$secret_file"
    else
        echo ""
    fi
}

# Set WP_ variables based on MARIADB_ variables or secrets if WP_ is not set
for var in WORDPRESS_USER WORDPRESS_PASSWORD DB_DATABASE DB_USER DB_USER_PASSWORD; do
	eval wp_var="\$${var}"

	# Check secrets
	## If secrets is mounted, export secret that has been read
   	wp_secret="/run/secrets/$(echo $var | tr '[:upper:]' '[:lower:]')"

	if [ -z "$wp_var" ] && [ -f "$wp_secret" ]; then
        	eval "export ${var}=$(read_secret "$wp_secret")"
    	fi

	# Check _FILE
	## If specific file is specified, read secret from it
   	eval wp_file_var="\$${var}_FILE"

	if [ -z "$wp_var" ] && [ -n "$wp_file_var" ]; then
		eval "export ${var}=$(read_secret "$wp_file_var")"
   	fi
done

#Verifier car comme un volume est monte, le DIR_PATH existe deja meme s'il est vide
if [ -d /wordpress_setup/sample.com ] && ! [ -f "$DIR_PATH/wp-config.php" ]; then
	echo "[i] Creating Wordpress Website"
	cp -R /wordpress_setup/sample.com/ "$DIR_PATH"
	cat > ~/.my.cnf << EOF
[mysql]
ssl-verify-server-cert=off
EOF
	until mariadb -h mariadb -u "$DB_USER" -p"$DB_USER_PASSWORD" "$DB_DATABASE" 2>/dev/null; do
		echo "[i] Waiting for Mariadb to be Up ..."
		sleep 1
	done
		echo "[i] Mariadb UP!"
		echo "Starting WP INSTALL"
	rm ~/.my.cnf
	wp-cli core install --path="$DIR_PATH" \
		--url=localhost \
		--title="Your website title" \
		--admin_user="$WORDPRESS_USER" \
		--admin_password="$WORDPRESS_PASSWORD" \
		--admin_email="your_email@example.com" \
			|| (rm "$DIR_PATH"/wp-config.php && exit 1)
	curl https://downloads.wordpress.org/plugin/redis-cache.2.5.4.zip --output redis-cache.2.5.4.zip
	wp-cli --path="$DIR_PATH" plugin install redis-cache.2.5.4.zip --activate
	wp-cli --path="$DIR_PATH" redis enable
else
	echo "[i] Skipping Wordpress creation"
	mv /wordpress_setup/sample.com/wp-config.php "$DIR_PATH"/
fi

chown -R www:www-data "$DIR_PATH"

cat << EOF
#############################
#           DEBUG           #
#############################
EOF

for var in WORDPRESS_USER WORDPRESS_PASSWORD DB_DATABASE DB_USER DB_USER_PASSWORD; do
    eval exp_var="\$${var}"

    echo "$var = ${exp_var}"
done

exec su - www -c 'php-fpm82 --nodaemonize'
