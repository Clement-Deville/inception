#!/bin/sh
DIR_PATH=/var/www/html/sample.com

#Verifier car comme un volume est monte, le DIR_PATH existe deja meme s'il est vide
if [ -d /wordpress_setup/sample.com ] && ! [ -d "$DIR_PATH" ]; then
	mv /wordpress_setup/sample.com "$DIR_PATH"
	curl https://downloads.wordpress.org/plugin/redis-cache.2.5.4.zip --output redis-cache.2.5.4.zip
	wp-cli plugin install redis-cache.2.5.4.zip –activate
	wp-cli redis enable
fi

chown -R www:www-data "$DIR_PATH" && chmod -R 755 "$DIR_PATH"

# start php-fpm
mkdir -p /usr/logs/php-fpm
chown -R www:www-data "/usr/logs/php-fpm" && chmod -R 755 "/usr/logs/php-fpm"

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
for var in WP_USER WP_PASSWORD DB_DATABASE DB_USER DB_USER_PASSWORD; do
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

# # Handle WP_PASSWORD
# if [ -n "$WP_PASSWORD_FILE" ]; then
# 	WP_PASSWORD=$(read_secret "$WP_PASSWORD_FILE")
# elif [ -f "/run/secrets/wp_password" ]; then
# 	WP_PASSWORD=$(read_secret "/run/secrets/wp_password")
# fi

# if [ -z "$WP_PASSWORD" ]; then
# 	WP_PASSWORD=$(pwgen 16 1)
# 	echo "[i] MySQL root Password: $WP_PASSWORD"
# fi

# # Handle WP_DATABASE
# if [ -n "$WP_DATABASE_FILE" ]; then
# 	WP_DATABASE=$(read_secret "$WP_DATABASE_FILE")
# elif [ -f "/run/secrets/database" ]; then
# 	WP_DATABASE=$(read_secret "/run/secrets/database")
# else
# 	WP_DATABASE=${WP_DATABASE:-""}
# fi

# # Handle WP_USER
# if [ -n "$WP_USER_FILE" ]; then
# 	WP_USER=$(read_secret "$WP_USER_FILE")
# elif [ -f "/run/secrets/wp_user" ]; then
# 	WP_USER=$(read_secret "/run/secrets/wp_user")
# else
# 	WP_USER=${WP_USER:-""}
# fi

# # Handle WP_PASSWORD
# if [ -n "$WP_PASSWORD_FILE" ]; then
# 	WP_PASSWORD=$(read_secret "$WP_PASSWORD_FILE")
# elif [ -f "/run/secrets/wp_password" ]; then
# 	WP_PASSWORD=$(read_secret "/run/secrets/wp_password")
# else
# 	WP_PASSWORD=${WP_PASSWORD:-""}
# fi

exec php-fpm82 --nodaemonize
