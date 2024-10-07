#!/bin/bash

source "/scripts/major_updates.sh"
source "/scripts/variables.sh"
source "/scripts/functions.sh"

if [ "$EUID" -ne 0 ]; then
	ERROR "Please run it as a root user!"
	exit 1
elif [ "$PUID" -eq 0 ] || [ "$PGID" -eq 0 ]; then
	ERROR "PUID/PGID cannot be set to 0."
	exit 1
elif [ ! -d "$VOLUME_ROOT" ]; then
	ERROR "$VOLUME_ROOT is not mounted."
	exit 1
fi



# pyenv init
mkdir -p "$PYENV_VERSIONS_SAVE_PATH"
test -e "$PYENV_ROOT/versions" || ln -s "$PYENV_VERSIONS_SAVE_PATH" "$PYENV_ROOT/versions"
eval "$(pyenv init -)"

ACTION "Change UID/PID"
INFO "User UID: $PUID"
INFO "User GID: $PGID"
usermod -o -u "$PUID" user > /dev/null 2>&1
groupmod -o -g "$PGID" user > /dev/null 2>&1
chown -R "$PUID":"$PGID" "$VOLUME_ROOT" "$PYENV_ROOT" /home/user /scripts



server_down() {
	pid="$(pgrep -f manage.py | tail -1)"
	kill -15 "$pid"
}
trap "server_down" 15



su user -c ./main.sh &
wait "$!"



mapfile -t backs < <(pgrep -f reverie.py)
if [ "${#backs[@]}" -ne 0 ]; then
	ACTION "Waiting for Backend to end..."
	for back in "${backs[@]}"; do
		tail -f --pid="$back" 2> /dev/null
	done
fi
