FROM alpine:3.16.2 as build

ARG UNBOUND_VERSION=release-1.17.0

RUN apk add --no-cache git gcc musl-dev linux-headers ca-certificates openssl-dev expat-dev make openssl byacc && \
    git clone --recursive https://github.com/NLnetLabs/unbound --branch ${UNBOUND_VERSION} /src && \
    cd /src && \
    /src/configure && \
    make && \
    sed -i 's|# username: "unbound"|username: "root"|g' doc/example.conf && \
    sed -i 's|# interface: 192.0.2.153|interface: 0.0.0.0|g' doc/example.conf && \
    sed -i 's|# interface: 192.0.2.154|interface: ::0|g' doc/example.conf && \
    sed -i 's|# access-control: 127.0.0.0/8 allow|access-control: 0.0.0.0/0 allow_snoop|g' doc/example.conf && \
    sed -i 's|# access-control: ::1 allow|access-control: ::0/0 allow_snoop|g' doc/example.conf && \
    sed -i 's|# auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"|auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"|g' doc/example.conf && \
    wget https://www.internic.net/domain/named.root -O /src/named.root
RUN /src/unbound-anchor -a /src/root.key; exit 0
    
FROM alpine:3.16.2
RUN apk add --no-cache ca-certificates bind-tools

COPY --from=build /src/unbound /usr/local/bin/unbound
COPY --from=build /src/root.key /usr/local/etc/unbound/root.key
COPY --from=build /src/doc/example.conf /usr/local/etc/unbound/unbound.conf
COPY --from=build /src/named.root /var/lib/unbound/root.hints

LABEL org.opencontainers.image.source="https://github.com/SanCraftDev/unbound-docker"
ENTRYPOINT ["unbound"]
CMD ["-d"]

HEALTHCHECK CMD dig example.com @127.0.0.1 || exit 1
