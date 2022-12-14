# unbound-docker

```yml
version: "3"
services:
    adguardhome:
        container_name: adguardhome
        image: adguard/adguardhome
        restart: always
        ports:
        - "80:80/tcp" # http web
        - "443:443/tcp" # https web / DoH
        - "443:443/udp" # https web (HTTP/3-QUIC) / DoH3
        - "127.0.0.1:53:53/tcp" # plain DNS
        - "127.0.0.1:53:53/udp" # plain DNS
        - "853:853/tcp" # DNS-over-TLS
        - "853:853/udp" # DNS-over-QUIC
#        - "784:784/udp" # DNS-over-QUIC
#        - "8853:8853/udp" # DNS-over-QUIC
#        - "5443:5443/tcp" # DNSCrypt
#        - "5443:5443/udp" # DNSCrypt
#        - "67:67/udp" # DHCP server
#        - "68:68/udp" # DHCP server
        - "3000:3000/tcp" # Only needed for the first time Setup
        volumes:
        - "/opt/adgh/work:/opt/adguardhome/work"
        - "/opt/adgh/conf:/opt/adguardhome/conf"
        - "/etc/ssl/fullchain-dns.pem:/etc/ssl/fullchain-dns.pem:ro"
        - "/etc/ssl/privkey-dns.pem:/etc/ssl/privkey-dns.pem:ro"
        dns:
        - 9.9.9.9
        - 149.112.112.112
        - 2620:fe::fe
        - 2620:fe::fe:9
        - 1.1.1.2
        - 1.0.0.2
        - 2606:4700:4700::1112
        - 2606:4700:4700::1002
        - 94.140.14.14
        - 94.140.15.15
        - 2a10:50c0::ad1:ff
        - 2a10:50c0::ad2:ff
        depends_on:
        - unbound
        links:
        - unbound
        networks:
          unbound:

    unbound:
        container_name: adguardhome-unbound
        image: zoeyvid/unbound-docker
        restart: always
        dns:
        - 9.9.9.9
        - 149.112.112.112
        - 2620:fe::fe
        - 2620:fe::fe:9
        - 1.1.1.2
        - 1.0.0.2
        - 2606:4700:4700::1112
        - 2606:4700:4700::1002
        - 94.140.14.14
        - 94.140.15.15
        - 2a10:50c0::ad1:ff
        - 2a10:50c0::ad2:ff
        networks:
          unbound:
            ipv4_address: 172.16.16.2
        
networks:
  unbound:
    ipam:
      driver: default
      config:
      - subnet: 172.16.16.0/24
```

Then use only `172.16.16.2` as your upstream server in AdGuard Home!
