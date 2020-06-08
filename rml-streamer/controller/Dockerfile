FROM alpine:3

RUN apk add --update curl bash jq && \
	rm -rf /var/cache/apk/*

COPY ./entrypoint.sh /entrypoint.sh

CMD ./entrypoint.sh
