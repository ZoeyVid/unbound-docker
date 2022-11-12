FROM alpine:20221110 as build

ARG UNBOUND_VERSION=release-1.17.0

RUN apk add --no-cache git gcc musl-dev linux-headers ca-certificates openssl-dev expat-dev make openssl byacc && \
    git clone --recursive https://github.com/NLnetLabs/unbound --branch ${UNBOUND_VERSION} /src && \
    cd /src && \
    /src/configure && \
    make
RUN /src/unbound-anchor -a /src/root.key || if [ "$?" == "1" ]; then exit 0; else exit 1; fi
    
FROM alpine:20221110
RUN apk add --no-cache ca-certificates bind-tools

COPY --from=build /src/unbound /usr/local/bin/unbound

COPY unbound.conf /usr/local/etc/unbound/unbound.conf
COPY --from=build /src/root.key /usr/local/etc/unbound/root.key
RUN wget https://www.internic.net/domain/named.root -O /usr/local/etc/unbound/root.hints

LABEL org.opencontainers.image.source="https://github.com/SanCraftDev/unbound-docker"
ENTRYPOINT ["unbound"]
CMD ["-dd", "-c", "/usr/local/etc/unbound/unbound.conf"]
HEALTHCHECK CMD dig example.com @127.0.0.1 || exit 1
