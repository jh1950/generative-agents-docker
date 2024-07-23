#!/bin/bash

source "/scripts/variables.sh"
source "/scripts/functions.sh"


if [ "$CUSTOM_UTILS" = false ]; then
	if [ -z "$OPENAI_API_KEY" ]; then
		IMPORTANT "To skip this step, set OPENAI_API_KEY"
		while read -rp "Your OpenAP API Key : " OPENAI_API_KEY; do
			test -n "$OPENAI_API_KEY" && break
		done
	fi
	if [ -z "$OPENAI_API_OWNER" ]; then
		IMPORTANT "To skip this step, set OPENAI_API_OWNER"
		while read -rp "Your OpenAP API Key : " OPENAI_API_OWNER; do
			test -n "$OPENAI_API_OWNER" && break
		done
	fi
fi

cd "$BACKEND_DIR" || exit 1
INFO "You can end press key Ctrl+c"
WARNING "But all operations are stopped."
ACTION "Back-end has been Started"
USER_RUN "$PYTHON" reverie.py
ACTION "Back-end is Stopped"
