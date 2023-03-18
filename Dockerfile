FROM alpine:3.17.2

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates tzdata unbound bind-tools && \
    wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints && \
    unbound-anchor -a /etc/unbound/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi

COPY unbound.conf    /etc/unbound/unbound.conf
COPY health-check.sh /usr/local/bin/health-check.sh

ENTRYPOINT ["unbound", "-dd"]
ENV dns=94.140.14.14
HEALTHCHECK CMD if [ "$(dig example.com IN A +short @127.0.0.1 | head -n 1)" != "$(dig example.com IN A +short +tls @"$dns" | head -n 1)" ]; then kill "$(cat /usr/local/etc/unbound/unbound.pid) && exit 1"; fi || exit 1
