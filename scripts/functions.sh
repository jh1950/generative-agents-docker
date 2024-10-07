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



# Functions

JOIN() {
	local IFS="$1"
	shift
	echo "$*"
}

GET_REPO_IN_URL() {
	local url="$1"
	awk -F "://|@|:|/" '{print $3 "/" $4}' <<< "$url"
}

FIND_SETTINGS_PY() {
	local TMP="$FRONTEND_SETTINGS_PY"

	if [ -z "$TMP" ] || [ "$TMP" == "auto" ]; then
		TMP="$(grep "os.environ.setdefault" "$FRONTEND_PATH/manage.py" | awk -F "'|)" '{print $4}' | tr "." "/")"
		if [ -d "$FRONTEND_PATH/$TMP" ]; then
			TMP="$TMP/local.py"
		else
			TMP="$TMP.py"
		fi
	fi

	echo "$FRONTEND_PATH/$TMP"
}

# Don't use settings that span multiple lines like INSTALLED_APPS, MIDDLEWARE
DJANGO_SETTING_CHANGE() {
	local key="$1"
	local val="$2"
	local file="$3"
	local full="$key = $val"

	if [ -z "$file" ]; then
		file="$(FIND_SETTINGS_PY)"
	fi
	if [ ! -f "$file" ]; then
		return 1
	fi
	if grep -q ^"$key.*=" "$file"; then
		sed -i "s/^$key.*/${full//\//\\\/}/g" "$file"
	else
		echo "$full" >> "$file"
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
