#!/bin/sh

if [ -z "$dns" ]; then
export dns=94.140.14.14
fi

if [ "$(dig example.com IN A +short @127.0.0.1 | head -n 1)" != "$(dig example.com IN A +short +tls @"$dns" | head -n 1)" ]; then
echo "dig failed, killing unbound..."
kill "$(cat /usr/local/etc/unbound/unbound.pid)"
exit 1
elif [ "$(dig example.com IN A +short @127.0.0.1 | head -n 1)" = "$(dig example.com IN A +short +tls @"$dns" | head -n 1)" ]; then
exit 0
else
echo "dig succeeded and failed, killing unbound..."
kill "$(cat /usr/local/etc/unbound/unbound.pid)"
exit 1
fi
