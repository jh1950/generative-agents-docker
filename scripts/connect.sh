#!/bin/bash

source "/scripts/variables.sh"
source "/scripts/functions.sh"



mode="${1,,}"
case "$mode" in
	shell)
		USER_RUN /bin/bash
		;;
	venv|django-shell)
		cd "$FRONTEND_PATH" || exit 1
		USER_RUN "$PYTHON" manage.py shell
		;;
	*)
		echo "Usage: ${0#**/} <shell|venv|django-shell>"
		;;
esac
