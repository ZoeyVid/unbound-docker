FROM alpine:3.19.1

RUN apk upgrade --no-cache -a && \
    apk add --no-cache ca-certificates tzdata tini unbound bind-tools && \
    wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints && \
    unbound-anchor -a /etc/unbound/root.key || true && \
    chown -R nobody:nobody /etc/unbound

COPY --chown=nobody:nobody unbound.conf /etc/unbound/unbound.conf

USER nobody:nobody
ENTRYPOINT ["tini", "--", "unbound-control", "start"]
HEALTHCHECK CMD if [ "$(dig example.org IN A +short @127.0.0.1 | grep '^[0-9.]\+$' | sort | head -n1)" != "$(dig example.org IN A +short +https +tls-ca=/etc/ssl/certs/ca-certificates.crt @1.1.1.1 | grep '^[0-9.]\+$' | sort | head -n1)" ]; then unbound-control stop; fi || exit 1
