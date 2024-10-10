#!/bin/bash

source "/scripts/notices.sh"
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



# pyenv init
mkdir -p "$PYENV_VERSIONS_SAVE_PATH"
test -e "$PYENV_ROOT/versions" || ln -s "$PYENV_VERSIONS_SAVE_PATH" "$PYENV_ROOT/versions"
eval "$(pyenv init -)"

ACTION "Change UID/PID"
INFO "User UID: $PUID"
INFO "User GID: $PGID"
usermod -o -u "$PUID" "$USER" > /dev/null 2>&1
groupmod -o -g "$PGID" "$USER" > /dev/null 2>&1
chown -R "$USER":"$USER" "$DATA_DIR" "$PYENV_ROOT" "/home/$USER" /scripts



server_down() {
	pid="$(pgrep -f manage.py | tail -1)"
	kill -15 "$pid"
}
trap "server_down" 15



su "$USER" -c ./main.sh &
wait "$!"



mapfile -t backs < <(pgrep -f reverie.py)
if [ "${#backs[@]}" -ne 0 ]; then
	ACTION "Waiting for Backend to end..."
	for back in "${backs[@]}"; do
		tail -f --pid="$back" 2> /dev/null
	done
fi
