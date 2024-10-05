#!/bin/bash

source "/scripts/variables.sh"
source "/scripts/functions.sh"



mode="${1,,}"
case "$mode" in
	shell)
		USER_RUN /bin/bash
		;;
	venv|django-shell)
		USER_RUN "$PYTHON" "$FRONTEND_DIR/manage.py" shell
		;;
	*)
		echo "Usage: connect [shell|venv|django-shell]"
		;;
esac
