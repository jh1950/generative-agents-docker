#!/bin/bash

source "./variables.sh"
source "./functions.sh"

if [ "$EUID" -ne 0 ]; then
	ERROR "Please run it as a root user!"
	return 1
elif [ ! -d "$DATA_DIR" ]; then
	ERROR "$DATA_DIR is not mounted."
	exit 1
fi

ACTION "Change UID/PID"
INFO "User PID: ${PUID}"
INFO "User GID: ${PGID}"
mkdir -p "$VENV_DIR"
usermod -o -u "${PUID}" user > /dev/null 2>&1
groupmod -o -g "${PGID}" user > /dev/null 2>&1
chown -R user:user "$DATA_DIR" "$VENV_DIR" /home/user

su user -c ./main.sh
