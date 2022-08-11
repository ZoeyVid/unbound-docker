FROM alpine:3.16.2 as build

ARG UNBOUND_VERSION=release-1.16.2

RUN apk add --no-cache --update git gcc musl-dev linux-headers ca-certificates openssl-dev expat-dev make openssl byacc && \
    git clone --recursive https://github.com/NLnetLabs/unbound --branch ${UNBOUND_VERSION} /src && \
    cd /src && \
    /src/configure && \
    make && \
    sed -i 's|# username: "unbound"|username: "root"|g' doc/example.conf && \
    sed -i 's|# interface: 192.0.2.153|interface: 0.0.0.0|g' doc/example.conf && \
    sed -i 's|# interface: 192.0.2.154|interface: ::0|g' doc/example.conf && \
    sed -i 's|# access-control: 0.0.0.0/0 refuse|access-control: 0.0.0.0/0 allow_snoop|g' doc/example.conf && \
    sed -i 's|# access-control: 127.0.0.0/8 allow|access-control: ::0/0 allow_snoop|g' doc/example.conf && \
    sed -i 's|# auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"|auto-trust-anchor-file: "/usr/local/etc/unbound/root.key"|g' doc/example.conf && \
    wget https://www.internic.net/domain/named.root -O /src/named.root
    
FROM busybox:1.35.0
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=build /src/unbound /usr/local/bin/unbound
#COPY --from=build /src/root.key /usr/local/etc/unbound/root.key
COPY --from=build /src/doc/example.conf /usr/local/etc/unbound/unbound.conf
COPY --from=build /src/named.root /var/lib/unbound/root.hints
COPY --from=build /lib/libssl.so.1.1 /lib/libssl.so.1.1
COPY --from=build /lib/libcrypto.so.1.1 /lib/libcrypto.so.1.1
COPY --from=build /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1

LABEL org.opencontainers.image.source="https://github.com/SanCraftDev/unbound-docker"
ENTRYPOINT ["unbound-anchor && unbound"]
CMD ["-d"]
