#!/bin/bash

source "/scripts/variables.sh"
source "/scripts/functions.sh"


if [ "$EUID" -ne 0 ]; then
	ERROR "Please run it as a root user!"
	exit 1
elif [ "$PUID" -eq 0 ] || [ "$PGID" -eq 0 ]; then
	ERROR "PUID/PGID cannot be set to 0."
	exit 1
elif [ ! -d "$DATA_DIR" ]; then
	ERROR "$DATA_DIR is not mounted."
	exit 1
fi


ACTION "Change UID/PID"
INFO "User UID: ${PUID}"
INFO "User GID: ${PGID}"
mkdir -p "$VENV_DIR"
usermod -o -u "${PUID}" user > /dev/null 2>&1
groupmod -o -g "${PGID}" user > /dev/null 2>&1
chown -R user:user "$DATA_DIR" "$VENV_DIR" /home/user /scripts


server_down() {
	pid="$(pgrep -f manage.py | tail -1)"
	kill -15 "$pid"
}
trap "server_down" 15


su user -c ./main.sh &
wait "$!"


ACTION "Waiting for Backend to end..."
while backs="$(pgrep -f reverie.py)"; do
	tail -f --pid="$(echo "$backs" | tail -1)"
done
