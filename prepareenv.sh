#!/bin/bash

USER_UID=$(id -u)
USER_GID=$(id -g)

echo "USER_UID=${USER_UID}" > .env
echo "USER_GID=${USER_GID}" >> .env

echo ".env файл успешно создан с USER_UID=${USER_UID} и USER_GID=${USER_GID}"
