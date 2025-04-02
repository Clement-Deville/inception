FROM alpine:3.9.4

RUN apk add --no-cache ca-certificates && apk -U upgrade\
	&& apk add --no-cache 	bash \
				openssl \ 
				vsftpd

RUN openssl req -x509 -nodes -days 7300 \
            -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem \
            -subj "/C=FR/O=My company/CN=example.org"

RUN mkdir -p /home/vsftpd/
RUN mkdir -p /var/log/vsftpd
RUN chown -R ftp:ftp /home/vsftpd/

COPY ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/run.sh /usr/sbin/run.sh

RUN chmod +x /usr/sbin/run.sh

EXPOSE 20-21 990 21100-21110
USER root
#STOPSIGNAL SIGKILL
CMD /usr/sbin/run.sh
