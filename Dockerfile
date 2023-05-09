FROM alpine:3.18.0

RUN apk add --no-cache ca-certificates tzdata unbound bind-tools && \
    wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints && \
    unbound-anchor -a /etc/unbound/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi

COPY unbound.conf /etc/unbound/unbound.conf

ENTRYPOINT ["unbound", "-dd"]
ENV dns=94.140.14.14
HEALTHCHECK CMD if [ "$(dig example.com IN A +short @127.0.0.1 | head -n 1)" != "$(dig example.com IN A +short +tls @"$dns" | head -n 1)" ]; then kill "$(cat /etc/unbound/unbound.pid)"; fi || exit 1
