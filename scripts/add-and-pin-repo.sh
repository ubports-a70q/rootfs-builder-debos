#!/bin/sh -e

# Work around resolver failure in debos' fakemachine
mv /etc/resolv.conf /etc/resolv2.conf
echo "nameserver 1.1.1.1" > /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

if [ "$#" -lt 3 ]; then
    echo "Usage: add-and-pin-repo.sh <URI> <repo> <priority> [<URI> <repo> <priority>]..."
    exit 1
fi

while [ "$#" -ge 3 ]; do
    URI=$1
    REPO=$2
    PRI=$3
    shift 3

    echo "deb $URI $REPO main" >> /etc/apt/sources.list.d/ubports.list

    origin=$(echo "$URI"|cut -d '/' -f 3) # Assume well-formed URI.

    echo "" >> /etc/apt/preferences.d/ubports.pref
    echo "Package: *" >> /etc/apt/preferences.d/ubports.pref
    echo "Pin: origin $origin" >> /etc/apt/preferences.d/ubports.pref
    echo "Pin: release o=UBports,a=$REPO" >> /etc/apt/preferences.d/ubports.pref
    echo "Pin-Priority: $PRI" >> /etc/apt/preferences.d/ubports.pref
done

if [ "$#" != 0 ]; then
    echo "Error: some arguments left over."
    exit 1
fi

apt-get update
apt-get upgrade -y --allow-downgrades
apt-get autoremove -y

# Undo changes to work around debos fakemachine resolver
rm /etc/resolv.conf
mv /etc/resolv2.conf /etc/resolv.conf
