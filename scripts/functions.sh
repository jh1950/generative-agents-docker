#!/bin/bash

# Beautiful Logs

RESET=0
# BLACK=30
RED=31
GREEN=32
YELLOW=33
# BLUE=34
MAGENTA=35
CYAN=36
WHITE=37

BOLD=true
BLIGHT=false
NEWLINE=true


ERROR() {
	LOG "$*" "$RED"
}

WARNING() {
	LOG "$*" "$YELLOW"
}

SUCCESS() {
	LOG "$*" "$GREEN"
}

IMPORTANT() {
	LOG "$*" "$MAGENTA"
}

INFO() {
	local BOLD=false
	LOG "$*" "$WHITE"
}

ACTION() {
	LOG "### $* ###" "$CYAN"
}

LOG() {
	local MSG="$1"
	local COLOR="$2"
	local NL=""

	if [ -z "$COLOR" ]; then
		INFO "$MSG"
		return
	fi
	test "$BLIGHT" = true && ((COLOR+=60))
	test "$BOLD" = true && COLOR="1;$COLOR"
	test "$NEWLINE" = true && NL="\n"

	echo -en "\e[${COLOR}m${MSG}\e[${RESET}m${NL}"
}

LOG_WITHOUT_NEWLINE() {
	local NEWLINE=false
	"$@"
}


GET_REPO_IN_URL() {
	local url="$1"
	awk -F ':|/' '{print $(NF-1) "/" $NF}' <<< "$url"
}

FIND_CONFIG_FILE() {
	local CONFIG_DIR

	if [ -z "$CONFIG_FILE" ]; then
		CONFIG_DIR="$(grep "os.environ.setdefault" "$FRONTEND_DIR/manage.py" | awk -F "'|)" '{print $4}' | tr "." "/")"
		if [ ! -d "$CONFIG_DIR" ]; then
			CONFIG_FILE="${CONFIG_DIR}.py"
		else
			CONFIG_FILE="$CONFIG_DIR/local.py"
		fi
	fi

	echo "$FRONTEND_DIR/$CONFIG_FILE"
}

# Don't use settings that span multiple lines like INSTALLED_APPS, MIDDLEWARE
DJANGO_CONFIG_SETTING() {
	local key="$1"
	local val="$2"
	local full="$key = $val"
	local CONFIG_FILE

	CONFIG_FILE="$(FIND_CONFIG_FILE)"
	if grep -q ^"$key.*=" "$CONFIG_FILE"; then
		sed -i "s/^$key.*/${full//\//\\\/}/g" "$CONFIG_FILE"
	else
		echo "$full" >> "$CONFIG_FILE"
	fi
}

USER_RUN() {
	local root=false

	if [ "$EUID" -eq 0 ]; then
		root=true
	elif [ "$(id -u)" -ne "$PUID" ] || [ "$(id -g)" -ne "$PGID" ]; then
		ERROR "Permission denied"
		return 1
	fi

	if [ "$root" = true ]; then
		if grep -q ^"$*"$ /etc/shells; then
			su user -s "$*"
		else
			su user -c "$*"
		fi
	else
		"$@"
	fi
	return "$?"
}
