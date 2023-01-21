#!/bin/sh

if [ "$(dig example.com @127.0.0.1 | grep -E ".*\..*\..*\..*" | grep "example\.com\." | head -n 1 | cut -f6)" != "$(dig example.com @"$dns" | grep -E ".*\..*\..*\..*" | grep "example\.com\." | head -n 1 | cut -f6)" ]; then
echo "dig failed, killing unbound..."
kill $(cat /usr/local/etc/unbound/unbound.pid)
exit 1
elif [ "$(dig example.com @127.0.0.1 | grep -E ".*\..*\..*\..*" | grep "example\.com\." | head -n 1 | cut -f6)" = "$(dig example.com @"$dns" | grep -E ".*\..*\..*\..*" | grep "example\.com\." | head -n 1 | cut -f6)" ]; then
exit 0
else
echo "dig succeeded and failed, killing unbound..."
kill "$(cat /usr/local/etc/unbound/unbound.pid)"
exit 1
fi
