#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin
### HANDLING VSFTPD SECRETS

# Function to read secret from file
read_secret() {
    local secret_file="$1"
    if [ -f "$secret_file" ] && [ -r "$secret_file" ]; then
        cat "$secret_file"
    else
        echo ""
    fi
}

# Set VSFTPD_ variables based on secrets
for var in VSFTPD_USER VSFTPD_PASSWORD; do
	eval vsftpd_var="\$${var}"

	# Check secrets
	## If secrets is mounted, export secret that has been read
   	vsftpd_secret="/run/secrets/$(echo $var | tr '[:upper:]' '[:lower:]')"

	if [ -z "$vsftpd_var" ] && [ -f "$vsftpd_secret" ]; then
        	eval "export ${var}=$(read_secret "$vsftpd_secret")"
    	fi

	# Check _FILE
	## If specific file is specified, read secret from it
   	eval vsftpd_file_var="\$${var}_FILE"

	if [ -z "$vsftpd_var" ] && [ -n "$vsftpd_file_var" ]; then
		eval "export ${var}=$(read_secret "$vsftpd_file_var")"
   	fi
done

echo "VSFTPD USER: $VSFTPD_USER"
echo "VSFTPD PASSWORD: $VSFTPD_PASSWORD"


# Define default values of Environment Variables
VSFTPD_USER=${VSFTPD_USER:-tssr}
VSFTPD_PASSWORD=${VSFTPD_PASSWORD:-tssr_passwd}
PASV_ENABLE=${PASV_ENABLE:-YES}
PASV_ADDRESS=${PASV_ADDRESS:-}
PASV_ADDRESS_INTERFACE=${PASV_ADDRESS_INTERFACE:-eth0}
PASV_ADDR_RESOLVE=${PASV_ADDR_RESOLVE:-NO}
PASV_MIN_PORT=${PASV_MIN_PORT:-21100}
PASV_MAX_PORT=${PASV_MAX_PORT:-21110}
FTP_MODE=${FTP_MODE:-ftp}
LOG_STDOUT=${LOG_STDOUT:-NO}

addgroup -g 433 -S "$VSFTPD_USER" 2> /dev/null
adduser -u 431 -D -G "$VSFTPD_USER" -h /home/vsftpd/"$VSFTPD_USER" -s /bin/false "$VSFTPD_USER" 2> /dev/null
ret="$?"
echo "[CHECK] Checking if inital setup has been done.."
if [ "$ret" -eq "0" ] ; then
	echo "--->[NO] Launching initial setup!"
	mkdir /home/vsftpd/"$VSFTPD_USER"/wordpress
	echo "$VSFTPD_USER:$VSFTPD_PASSWORD" | /usr/sbin/chpasswd
	chown "$VSFTPD_USER:$VSFTPD_USER" /home/vsftpd/"$VSFTPD_USER"
	echo "local_root=/mnt/wordpress" > /etc/vsftpd/vsftpd_user_conf/"$VSFTPD_USER"
else
	echo "--->[YES] Skipping initial setup!"
fi

PASV_ADDRESS=$(ip -o -4 addr list "$PASV_ADDRESS_INTERFACE" | head -n1 | awk '{print $4}' | cut -d/ -f1)

# Building the configuration file
VSFTPD_CONF=/etc/vsftpd/vsftpd.conf

# Update the vsftpd-ftp.conf according to env variables
echo "Update the vsftpd.conf according to env variables"
echo "" >> "$VSFTPD_CONF"
echo "# the following config lines are added by the run-vsftpd.sh script for passive mode" >> "$VSFTPD_CONF"
echo "anonymous_enable=NO" >> "$VSFTPD_CONF"
echo "pasv_enable=$PASV_ENABLE" >> "$VSFTPD_CONF"
echo "pasv_address=$PASV_ADDRESS" >> "$VSFTPD_CONF"
echo "pasv_addr_resolve=$PASV_ADDR_RESOLVE" >> "$VSFTPD_CONF"
echo "pasv_max_port=$PASV_MAX_PORT" >> "$VSFTPD_CONF"
echo "pasv_min_port=$PASV_MIN_PORT" >> "$VSFTPD_CONF"

cat << EOB
  SERVER SETTINGS
  ---------------
  . VSFTPD_USER: "${VSFTPD_USER}"
  . VSFTPD_PASSWORD: "${VSFTPD_PASSWORD}"
  . PASV_ENABLE: "${PASV_ENABLE}"
  . PASV_ADDRESS: "${PASV_ADDRESS}"
  . PASV_ADDRESS_INTERFACE: "${PASV_ADDRESS_INTERFACE}"
  . PASV_ADDR_RESOLVE: "${PASV_ADDR_RESOLVE}"
  . PASV_MIN_PORT: "${PASV_MIN_PORT}"
  . PASV_MAX_PORT: "${PASV_MAX_PORT}"
  . FTP_MODE: "${FTP_MODE}"
  . LOG_STDOUT: "${LOG_STDOUT}"
  . LOG_FILE: "${LOG_FILE}"
EOB


# Run the vsftpd server
echo "Running vsftpd"

#exec /usr/sbin/vsftpd -foreground /etc/vsftpd/vsftpd.conf

## IF YOU DONT WANT VSFTPD TO BE THE MAIN PROCESS, COMMENT PREVIEW EXEC AND UNCOMMENT NEXT LINES

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &

sleep 1
process_id=$(/bin/ps | /bin/grep 'vsftpd' | /bin/grep -v "grep" | awk '{print $1}')

# WAIT FOR CONTAINER TO TERMINATE AND KILL VSFTPD TO STOP FASTER
trap 'quit=1' SIGTERM SIGINT
quit=0
while [ "$quit" -ne 1 ]; do
    /bin/sleep 1
done
/bin/echo "Preparing to kill vsftpd of pid $process_id"
/bin/kill "$process_id"
wait "$process_id"
/bin/echo "$process_id" was terminated by a SIG"$(/bin/kill -l "$?")" signal

echo "[i] Killing other processes"

for pid in $(ps -eo pid | grep -vE '^( *1| *PID| *'"$$"')'); do
	kill -TERM "$pid" 2>/dev/null
done

sleep 2

for pid in $(ps -eo pid | grep -vE '^( *1| *PID| *'"$$"')'); do
	kill -KILL "$pid" 2>/dev/null
done

echo "✅ Nettoyage terminé."
exit 0
