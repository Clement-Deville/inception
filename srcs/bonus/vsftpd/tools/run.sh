#!/bin/bash

# Define default values of Environment Variables
FTP_USER=${FTP_USER:-tssr}
FTP_PASS=${FTP_PASS:-tssr_passwd}
PASV_ENABLE=${PASV_ENABLE:-YES}
PASV_ADDRESS=${PASV_ADDRESS:-}
PASV_ADDRESS_INTERFACE=${PASV_ADDRESS_INTERFACE:-eth0}
PASV_ADDR_RESOLVE=${PASV_ADDR_RESOLVE:-NO}
PASV_MIN_PORT=${PASV_MIN_PORT:-21100}
PASV_MAX_PORT=${PASV_MAX_PORT:-21110}
FTP_MODE=${FTP_MODE:-ftp}
LOG_STDOUT=${LOG_STDOUT:-NO}

addgroup -g 433 -S $FTP_USER 2> /dev/null
adduser -u 431 -D -G $FTP_USER -h /home/vsftpd/$FTP_USER -s /bin/false $FTP_USER 2> /dev/null
ret=`echo $?`
echo "[CHECK] Checking if inital setup has been done.."
if [ "$ret" -eq "0" ] ; then 
	echo "--->[NO] Launching initial setup!"
	mkdir /home/vsftpd/$FTP_USER/wordpress
	echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd
	chown $FTP_USER:$FTP_USER /home/vsftpd/$FTP_USER
else
	echo "--->[YES] Skipping initial setup!"
fi
PASV_ADDRESS=$(ip -o -4 addr list $PASV_ADDRESS_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)

# Building the configuration file
VSFTPD_CONF=/etc/vsftpd/vsftpd.conf
#more /etc/vsftpd/vsftpd-base.conf > $VSFTPD_CONF

# Update the vsftpd-ftp.conf according to env variables
echo "Update the vsftpd.conf according to env variables"
echo "" >> $VSFTPD_CONF
echo "# the following config lines are added by the run-vsftpd.sh script for passive mode" >> $VSFTPD_CONF
echo "anonymous_enable=NO" >> $VSFTPD_CONF
echo "pasv_enable=$PASV_ENABLE" >> $VSFTPD_CONF
echo "pasv_address=$PASV_ADDRESS" >> $VSFTPD_CONF
echo "pasv_addr_resolve=$PASV_ADDR_RESOLVE" >> $VSFTPD_CONF
echo "pasv_max_port=$PASV_MAX_PORT" >> $VSFTPD_CONF
echo "pasv_min_port=$PASV_MIN_PORT" >> $VSFTPD_CONF

cat << EOB
  SERVER SETTINGS
  ---------------
  . FTP_USER: "${FTP_USER}"
  . FTP_PASS: "${FTP_PASS}"
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
process_id=`/bin/ps | /bin/grep 'vsftpd' | /bin/grep -v "grep" | awk '{print $1}'`

# WAIT FOR CONTAINER TO TERMINATE AND KILL VSFTPD TO STOP FASTER
trap 'quit=1' SIGTERM SIGINT
quit=0
while [ "$quit" -ne 1 ]; do
    sleep 1
done
echo "Preparing to kill vsftpd of pid $process_id"
kill $process_id
wait $process_id
echo $pid was terminated by a SIG$(kill -l $?) signal
