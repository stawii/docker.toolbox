#!/bin/sh

[ "$$" -eq 1 ] && exec /tini -- "$0" "$@"

exec tail -f /dev/null
