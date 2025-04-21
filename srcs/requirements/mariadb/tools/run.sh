#!/bin/sh

# Function to read secret from file
read_secret() {
    local secret_file="$1"
    if [ -f "$secret_file" ] && [ -r "$secret_file" ]; then
        cat "$secret_file"
    else
        echo ""
    fi
}

# Set MYSQL_ variables based on MARIADB_ variables or secrets if MYSQL_ is not set
for var in ROOT_PASSWORD DATABASE USER PASSWORD CHARSET COLLATION; do
    eval mysql_var="\$MYSQL_${var}"
    eval mariadb_var="\$MARIADB_${var}"

    # Check secrets
    mysql_secret="/run/secrets/db_$(echo $var | tr '[:upper:]' '[:lower:]')"

    if [ -z "$mysql_var" ] && [ -f "$mysql_secret" ]; then
        eval "export MYSQL_${var}=$(read_secret "$mysql_secret")"
    fi
done

# Handle *_FILE variables
for var in ROOT_PASSWORD DATABASE USER PASSWORD; do
   eval mysql_var="\$MYSQL_${var}"
   eval mysql_file_var="\$MYSQL_${var}_FILE"

   if [ -z "$mysql_var" ] && [ -n "$mysql_file_var" ]; then
       eval "export MYSQL_${var}=$(read_secret "$mysql_file_var")"
   fi
done

if [ -d "/run/mysqld" ]; then
    echo "[i] mysqld already present, skipping creation"
    chown -R mysql:mysql /run/mysqld
else
    echo "[i] mysqld not found, creating...."
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
    echo "[i] MySQL directory already present, skipping creation"
    chown -R mysql:mysql /var/lib/mysql
else
	echo "[i] DB data directory not found, creating initial DBs"

	chown -R mysql:mysql /var/lib/mysql
    # Initializes the MySQL data directory and creates the system tables that it contains

    mysql_install_db 	--user=mysql \
	    		--ldata=/var/lib/mysql  > /dev/null

    # Handle MYSQL_ROOT_PASSWORD
    if [ -n "$MYSQL_ROOT_PASSWORD_FILE" ]; then
        MYSQL_ROOT_PASSWORD=$(read_secret "$MYSQL_ROOT_PASSWORD_FILE")
    elif [ -f "/run/secrets/db_root_password" ]; then
        MYSQL_ROOT_PASSWORD=$(read_secret "/run/secrets/db_root_password")
    fi

    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        MYSQL_ROOT_PASSWORD=$(pwgen 16 1)
        echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
    fi

    # Handle MYSQL_DATABASE
    if [ -n "$MYSQL_DATABASE_FILE" ]; then
        MYSQL_DATABASE=$(read_secret "$MYSQL_DATABASE_FILE")
    elif [ -f "/run/secrets/db_database" ]; then
        MYSQL_DATABASE=$(read_secret "/run/secrets/db_database")
    else
        MYSQL_DATABASE=${MYSQL_DATABASE:-""}
    fi

    # Handle MYSQL_USER
    if [ -n "$MYSQL_USER_FILE" ]; then
        MYSQL_USER=$(read_secret "$MYSQL_USER_FILE")
    elif [ -f "/run/secrets/db_user" ]; then
        MYSQL_USER=$(read_secret "/run/secrets/db_user")
    else
        MYSQL_USER=${MYSQL_USER:-""}
    fi

    # Handle MYSQL_PASSWORD
    if [ -n "$MYSQL_PASSWORD_FILE" ]; then
        MYSQL_PASSWORD=$(read_secret "$MYSQL_PASSWORD_FILE")
    elif [ -f "/run/secrets/db_user_password" ]; then
        MYSQL_PASSWORD=$(read_secret "/run/secrets/db_user_password")
    else
        MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}
    fi

    tfile=$(mktemp)
    if [ ! -f "$tfile" ]; then
        return 1
    fi

    cat << EOF > "$tfile"
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

    if [ "$MYSQL_DATABASE" != "" ]; then
        echo "[i] Creating database: $MYSQL_DATABASE"
        if [ "$MYSQL_CHARSET" != "" ] && [ "$MYSQL_COLLATION" != "" ]; then
            echo "[i] with character set [$MYSQL_CHARSET] and collation [$MYSQL_COLLATION]"
            echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET $MYSQL_CHARSET COLLATE $MYSQL_COLLATION;" >> "$tfile"
        else
            echo "[i] with character set: 'utf8' and collation: 'utf8_general_ci'"
            echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> "$tfile"
        fi

        if [ "$MYSQL_USER" != "" ]; then
            echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> "$tfile"
        fi
    fi

	## Launching Mysql to create and apply configuration

    /usr/bin/mysqld --user=mysql --bootstrap --skip-name-resolve --skip-networking=0 < "$tfile"
    rm -f "$tfile"

    echo
    echo 'MySQL init process done. Ready for start up.'
    echo

    echo "exec /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0" "$@"
fi

exec /usr/bin/mysqld --user=mysql --console --skip-name-resolve --skip-networking=0 "$@"
