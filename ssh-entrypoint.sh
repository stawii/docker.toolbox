#!/bin/sh

[ "$$" -eq 1 ] && exec /tini -- "$0" "$@"

ssh-keygen -A || exit 1
mkdir -p /run/sshd
exec /usr/sbin/sshd -De
