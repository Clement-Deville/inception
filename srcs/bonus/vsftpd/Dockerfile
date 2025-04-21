FROM alpine:3.9.4

RUN apk add --no-cache ca-certificates && apk -U upgrade\
	&& apk add --no-cache 	bash \
				openssl \
				vsftpd

RUN openssl req -x509 -nodes -days 7300 \
            -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem \
            -subj "/C=FR/O=My company/CN=example.org"

RUN mkdir -p /home/vsftpd/ \
	&& mkdir -p /var/log/vsftpd \
	&& chown -R ftp:ftp /home/vsftpd/ \
	&& mkdir /etc/vsftpd/vsftpd_user_conf/

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY --chmod=700 ./tools/run.sh /usr/sbin/run.sh

EXPOSE 20-21 990 21100-21110

CMD /usr/sbin/run.sh
