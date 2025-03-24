FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk -U upgrade \
	&& apk add --no-cache redis \
	&& apk add --no-cache git \
	&& rm -f /var/cache/apk/* 

COPY ./tools/run.sh /bin/run.sh
EXPOSE 6379
CMD ["/bin/run.sh", "daemon off"]
