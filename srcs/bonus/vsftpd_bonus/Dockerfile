FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk -U upgrade && apk add --no-cache vsftpd
USER root

RUN addgroup ftpusers && adduser -G ftpusers tssr 2> /dev/null || echo lol\
	&& mkdir -p /srv/ftp && chown root:ftpusers /srv/ftp && chmod 770 /srv/ftp && mkdir /home/tssr/uploads \
	&& chown tssr:ftpusers /home/tssr/uploads && chmod 755 /home/tssr/uploads && chmod a-w /home/tssr

COPY --chown=tssr:ftpusers ./conf/vsftpd.userlist /etc/vsftpd.userlist
COPY --chown=tssr:ftpusers ./conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY ./tools/run.sh /setup/run.sh

EXPOSE 21
CMD ["/setup/run.sh", "daemon off"]
