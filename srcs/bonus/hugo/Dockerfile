FROM alpine:3.21.2

RUN apk add --no-cache ca-certificates && apk -U upgrade \
	&& apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community hugo \
	&& apk add --no-cache git \
	&& rm -f /var/cache/apk/*

COPY ./tools/run.sh /bin/run.sh
COPY ./conf/hugo.yaml /hugo.yaml

EXPOSE 1313

CMD ["/bin/run.sh", "daemon off"]
