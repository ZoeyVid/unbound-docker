FROM alpine:20221110 as build

ARG UNBOUND_VERSION=release-1.17.0

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata git make gcc byacc musl-dev openssl-dev expat-dev linux-headers && \
    git clone --recursive https://github.com/NLnetLabs/unbound --branch ${UNBOUND_VERSION} /src && \
    cd /src && \
    /src/configure && \
    make
RUN /src/unbound-anchor -a /src/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi
RUN wget https://www.internic.net/domain/named.root -O /src/root.hints

FROM alpine:20221110

COPY --from=build /src/unbound    /usr/local/bin/unbound

COPY --from=build /src/root.key   /usr/local/etc/unbound/root.key
COPY --from=build /src/root.hints /usr/local/etc/unbound/root.hints
COPY              unbound.conf    /usr/local/etc/unbound/unbound.conf
COPY              health-check    /usr/local/bin/health-check

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata bind-tools && \
    chmod +x /usr/local/bin/health-check

ENTRYPOINT ["unbound", "-dd"]
HEALTHCHECK CMD health-check || exit 1
