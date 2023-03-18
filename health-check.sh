#!/bin/sh

if [ "$(dig example.com IN A +short @127.0.0.1 | head -n 1)" = "$(dig example.com IN A +short +tls @"$dns" | head -n 1)" ]; then
  exit 0
else
  echo "dig failed, killing unbound..."
  kill "$(cat /usr/local/etc/unbound/unbound.pid)"
  exit 1
fi
