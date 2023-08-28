#!/bin/sh
set -e

echo "***** Start SSH server *****"
mkdir -p /run/sshd
/usr/sbin/sshd

exec "$@"
