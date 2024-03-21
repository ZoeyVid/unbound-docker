FROM alpine:3.19.1

RUN apk add --no-cache ca-certificates tzdata tini unbound bind-tools && \
    wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints && \
    unbound-anchor -a /etc/unbound/root.key || true && \
    chown -R nobody:nobody /etc/unbound

COPY --chown=nobody:nobody unbound.conf /etc/unbound/unbound.conf

USER nobody:nobody
ENTRYPOINT ["tini", "--", "unbound-control", "start"]
ENV dns=94.140.14.14
HEALTHCHECK CMD if [ "$(dig example.com IN A +short @127.0.0.1 | sort | head -n 1)" != "$(dig example.com IN A +short +tls @"$dns" | sort | head -n 1)" ]; then unbound-control stop; fi || exit 1
