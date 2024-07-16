#!/bin/bash

# Beautiful Logs

RESET=0
# BLACK=30
RED=31
GREEN=32
YELLOW=33
# BLUE=34
PURPLE=35
CYAN=36
WHITE=37

BOLD=true
LIGHT=false
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
	LOG "$*" "$PURPLE"
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
	local NL="\n"

	if [ -z "$COLOR" ]; then
		local BOLD=""
		local LIGHT=false
		COLOR="$WHITE"
	fi
	test "$LIGHT" = true && ((COLOR+=60))
	test "$BOLD" = true && COLOR="1;$COLOR"
	test "$NEWLINE" = true && NL="\n"

	echo -en "\e[${COLOR}m${MSG}\e[${RESET}m${NL}"
}
