#!/bin/sh -e

set -e

# shellcheck disable=SC1091
. /etc/os-release

if [ "$VERSION_CODENAME" = "xenial" ]; then
    # Work around resolver failure in debos' fakemachine
    mv /etc/resolv.conf /etc/resolv2.conf
    echo "nameserver 1.1.1.1" > /etc/resolv.conf
fi

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

if [ -n "$APT_PROXY" ]; then
    alias apt-get="apt-get -o Acquire::http::Proxy='$APT_PROXY'"
fi

apt-get update
apt-get install -y "$@"

if [ "$VERSION_CODENAME" = "xenial" ]; then
    # Undo changes to work around debos fakemachine resolver
    rm /etc/resolv.conf
    mv /etc/resolv2.conf /etc/resolv.conf
fi
