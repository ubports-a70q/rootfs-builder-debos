#!/bin/sh

dir=$(dirname "$0")

case "$1" in
    chroot_early|chroot)
        ;;
    *)
        echo "Invalid hook type $1." >&2
        exit 1
esac

# VARIANT can be used by the hooks to do different things on different variants.
export VARIANT="$2"

exec run-parts --verbose --exit-on-error --regex="^[0-9]{2}.*\.$1\$" -- "$dir"
