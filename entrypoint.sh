#!/bin/bash
mkdir -p /data/config /data/world
chown -R ${USER_UID}:${USER_GID} /data/config /data/world
chmod -R 755 /data/config /data/world
exec "$@"
