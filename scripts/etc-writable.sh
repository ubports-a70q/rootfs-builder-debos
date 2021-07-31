#!/bin/bash
# Systemd and friends are patched to look in /etc/writable for timezone,
# hostname, and machine type information.

set -e

mkdir -p /etc/writable

for f in timezone localtime hostname machine-info; do
    if ! [ -e /etc/writable/$f ]; then
        # Try to prevent circular loop
        if [ -e /etc/$f ] && ! [[ "$(readlink -f /etc/$f)" =~ ^/etc/writable ]]; then
            echo "I: Moving /etc/$f to /etc/writable/"
            mv /etc/$f /etc/writable/$f
        else
            echo "I: Making sure /etc/writable/$f is available"
            touch /etc/writable/$f
        fi
    fi

    echo "I: Linking /etc/$f to /etc/writable/"
    ln -sf writable/$f /etc/$f
done
