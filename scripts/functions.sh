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

# Returns 0 if exists the regular file
# Returns 1 if not exists the regular file
FILE_EXISTS() {
	local path="$1"
	test -f "$path" || return 1
}

# Returns 0 if exists the directory
# Returns 1 if not exists the directory
DIR_EXISTS() {
	local path="$1"
	test -d "$path" || return 1
}

JOIN() {
	local IFS="$1"
	shift
	echo "$*"
}

# Returns 0 if successful or already installed
# Returns 1 if not found version
INSTALL_PYTHON() {
	local PYTHON_VERSION="$1"
	local VIRTUALENV_NAME="$2"

	if ! pyenv install --list | grep -Eq ^"[[:blank:]]?+$PYTHON_VERSION"$; then
		return 1
	fi

	pyenv install "$PYTHON_VERSION"
	pyenv virtualenv "$PYTHON_VERSION" "$VIRTUALENV_NAME"
	touch "$PYENV_VERSIONS/$VIRTUALENV_NAME/.installed"
}

# Returns 0 if update required
# Returns 1 if not update required
# Returns 2 if not found requirements.txt
# Outputs: temp file
MODULE_UPDATE_REQUIRED() {
	local REQS_PATH="$1"
	local VIRTUALENV_NAME="$2"
	local tmp_file

	FILE_EXISTS "$REQS_PATH" || return 2
	tmp_file="$(mktemp)"
	echo "$tmp_file"

	sha256sum <<< "$(cat "$REQS_PATH")$VIRTUALENV_NAME" | awk '{print $1}' > "$tmp_file"
	if diff "$PYENV_VERSIONS/$VIRTUALENV_NAME/.installed" "$tmp_file" > /dev/null 2>&1; then
		return 1
	else
		return 0
	fi
}

# Returns 0 if successful or already installed
# Returns 1 if module installation error
# Returns 2 if not found requirements.txt
INSTALL_PYTHON_MODULES() {
	local DIR="$1"
	local REQS_PATH="$2"
	local VIRTUALENV_NAME="$3"
	local tmp_file

	FILE_EXISTS "$REQS_PATH" || return 2
	cd "$DIR" || return

	if tmp_file="$(MODULE_UPDATE_REQUIRED "$REQS_PATH" "$VIRTUALENV_NAME")"; then
		$PYENV_VERSIONS/$VIRTUALENV_NAME/bin/pip3 install -U pip
		$PYENV_VERSIONS/$VIRTUALENV_NAME/bin/pip3 install -Ur "$REQS_PATH" || return 1
		mv "$tmp_file" "$PYENV_VERSIONS/$VIRTUALENV_NAME/.installed"
	fi
}

# Inputs:
#  - https://github.com/user/repo/path/to/...
#  - git@github.com:user/repo
# Outputs: user/repo
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
	if ! FILE_EXISTS "$file"; then
		return 1
	fi
	if grep -q ^"$key.*=" "$file"; then
		sed -i "s/^$key.*/${full//\//\\\/}/g" "$file"
	else
		echo "$full" >> "$file"
	fi
}

# Always run with PUID/PGID
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
			su "$USER" -s "$*"
		else
			su "$USER" -c "$*"
		fi
	else
		"$@"
	fi
	return "$?"
}
