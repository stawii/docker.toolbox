#!/bin/sh

[ "$$" -eq 1 ] && exec /tini -- "$0" "$@"

cd "${SIMPLE_WEBROOT?}" || exit 1
exec python3 -m http.server
