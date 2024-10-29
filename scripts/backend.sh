#!/bin/bash

source "/scripts/variables.sh"
source "/scripts/functions.sh"



args=()
while [ "${#@}" -ne 0 ]; do
	case "$1" in
		"--background")
			BACKGROUND="&"
			;;
		"-"*)
			INFO "Unknown Option: $1"
			;;
		*)
			args+=("$1")
	esac
	shift
done



if [ "$BACKGROUND" == "&" ] && [ "${#args[@]}" -lt 3 ]; then
	INFO "Using: backend [<FORKED_SIMULATION> <NEW_SIMULATION> [OPTION...]]"
	INFO "Using: backend --background <FORKED_SIMULATION> <NEW_SIMULATION> [OPTION...]"
	exit 1
fi



if [ "$BACKEND_CUSTOM_UTILS_PY" = true ]; then
	if [ ! -f "$BACKEND_PATH/utils.py" ]; then
		INFO "Copy utils.py to ${BACKEND_PATH#/}/utils.py"
		INFO "Waiting..."
		while [ ! -f "$BACKEND_PATH/utils.py" ]; do
			sleep 1s
		fi
	fi
else
	if [ -z "$OPENAI_API_KEY" ]; then
		IMPORTANT "To skip this step, set env OPENAI_API_KEY"
		while [ -z "$OPENAI_API_KEY" ]; do
			printf "Your OpenAP API Key : "
			read -r OPENAI_API_KEY
			OPENAI_API_KEY="$(xargs <<< "$OPENAI_API_KEY")"
		done
		export OPENAI_API_KEY
	fi
	if [ -z "$OPENAI_API_OWNER" ]; then
		IMPORTANT "To skip this step, set env OPENAI_API_OWNER"
		while [ -z "$OPENAI_API_OWNER" ]; do
			printf "Your OpenAP API Owner : "
			read -r OPENAI_API_OWNER
			OPENAI_API_OWNER="$(xargs <<< "$OPENAI_API_OWNER")"
		done
		export OPENAI_API_OWNER
	fi
fi



cd "$BACKEND_PATH" || exit 1
ACTION "Back-end has been Started"
if [ "$BACKGROUND" != "&" ]; then
	LOG_WITHOUT_NEWLINE INFO  "Press Ctrl+c to "
	LOG_WITHOUT_NEWLINE ERROR "force exit"
	LOG_WITHOUT_NEWLINE INFO  ", double press to exit immediately"
	echo
fi

if [ "${#args[@]}" -ge 3 ]; then
	USER_RUN "$PYTHON" reverie.py "<<<" "\"$(JOIN $'\n' "${args[@]}")\"" "$BACKGROUND"
else
	USER_RUN "$PYTHON" reverie.py
	ACTION "Back-end is Stopped"
fi
