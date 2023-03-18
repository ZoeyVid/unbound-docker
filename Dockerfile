FROM alpine:3.17.2

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates tzdata unbound bind-tools && \
    wget https://www.internic.net/domain/named.root -O /etc/unbound/root.hints && \
    unbound-anchor -a /etc/unbound/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi

COPY unbound.conf    /etc/unbound/unbound.conf
COPY health-check.sh /usr/local/bin/health-check.sh

ENTRYPOINT ["unbound", "-dd"]
HEALTHCHECK CMD health-check.sh || exit 1
