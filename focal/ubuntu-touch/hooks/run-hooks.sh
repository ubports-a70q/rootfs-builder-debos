#!/bin/sh

dir=$(dirname "$0")

exec run-parts --report --exit-on-error --regex='^[0-9]{2}-.*' -- "$dir"