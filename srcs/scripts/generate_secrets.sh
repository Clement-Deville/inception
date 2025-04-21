#!/bin/sh

DIR=./secrets
PATH=/bin:/sbin:/usr/bin:/usr/sbin

echo "[i] Creating secrets dir if it doesn't exist"

if ! [ -d ${DIR} ]; then
    mkdir ${DIR}
fi

for var in db_root_password db_database db_user db_user_password \
    wordpress_user wordpress_password \
    adminer_user adminer_password \
    vsftpd_user vsftpd_password \
	auth_user auth_password; do
    if ! [ -f "${DIR}/${var}.txt" ] && ! [ -r "${DIR}/${var}.txt" ]; then
        echo "[i] Creating ${DIR}/${var}.txt.."
        touch ${DIR}/${var}.txt
    fi
done

for key in nginx vsftpd; do
	if ! [ -f "${DIR}/${key}.key" ] && ! [ -r "${DIR}/${key}.key" ]; then
		echo "[i] Generating ${key} SSL key"
		openssl req -x509 -nodes -days 365 \
			-newkey rsa:4096 \
			-keyout ${DIR}/${key}.key \
			-out ${DIR}/${key}.crt \
			-subj "/C=XX/ST=XX/L=XX/O=XX/OU=XX/CN=XX" \
				|| { echo "Failed to generate SSL Keys"; exit 1; }
		echo "[i] SSL key successfully generated "
	else
		echo "[i] ${key} SSL key already created"
	fi
done
chmod 700 -R ./secrets

cat << EOF

This script itends to generate all the files required to store secrets.
You will have to write inside the value of your secret, for example:
echo "my_secret_password" > password.txt

Also, an SSL certificate is generated for as "autosigned".
EOF

# for var in root_password database user password; do
#     echo "[i] Checking if db_${var}.txt already exist .."
#     if [ -f "db_${var}.txt" ] && [ -r "db_${var}.txt"]; then
#         echo "[i] File db_${var}.txt already exist"
#     else
#         echo "[i] File db_${var}.txt doesn't exist\nChoose your db_${var} secret: "
#         cat > secrets/db_${var}.txt
#         echo "[i] File db_${var}.txt has been created with the secret"
#     fi
# done
