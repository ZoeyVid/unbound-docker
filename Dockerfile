FROM alpine:20230208 as build

ARG UNBOUND_VERSION=release-1.17.1

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata git build-base linux-headers openssl-dev expat-dev && \
    git clone --recursive https://github.com/NLnetLabs/unbound --branch ${UNBOUND_VERSION} /src && \
    cd /src && \
    /src/configure && \
    make
RUN /src/unbound-anchor -a /src/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi
RUN wget https://www.internic.net/domain/named.root -O /src/root.hints

FROM alpine:20230208
COPY --from=build /src/unbound    /usr/local/bin/unbound
COPY --from=build /src/root.key   /usr/local/etc/unbound/root.key
COPY --from=build /src/root.hints /usr/local/etc/unbound/root.hints
COPY              unbound.conf    /usr/local/etc/unbound/unbound.conf
COPY --chmod=744  health-check.sh /usr/local/bin/health-check.sh

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates wget tzdata bind-tools

ENTRYPOINT ["unbound", "-dd"]
HEALTHCHECK CMD health-check.sh || exit 1
