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
RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata bind-tools

COPY --from=build /src/unbound    /usr/local/bin/unbound

COPY --from=build /src/root.key   /usr/local/etc/unbound/root.key
COPY --from=build /src/root.hints /usr/local/etc/unbound/root.hints
COPY              unbound.conf    /usr/local/etc/unbound/unbound.conf

ENTRYPOINT unbound -dd
HEALTHCHECK CMD dig example.com @127.0.0.1 || exit 1
