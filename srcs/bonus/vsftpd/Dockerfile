FROM alpine:3.9.4

RUN apk add --no-cache ca-certificates && apk -U upgrade\
	&& apk add --no-cache 	bash \
				openssl \
				vsftpd

RUN mkdir -p /home/vsftpd/ \
	&& mkdir -p /var/log/vsftpd \
	&& chown -R ftp:ftp /home/vsftpd/ \
	&& mkdir /etc/vsftpd/vsftpd_user_conf/

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY --chmod=700 ./tools/run.sh /usr/sbin/run.sh

EXPOSE 20-21 990 21100-21110

CMD /usr/sbin/run.sh
