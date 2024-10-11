#!/bin/bash

source "/scripts/functions.sh"

# v0 to v1
if [ "$REPO_URL" != "unused" ] && [ "$SERVER_INSTALL_URL" == "https://github.com/joonspk-research/generative_agents" ]; then
	WARNING "REPO_URL will no longer be used, Use SERVER_INSTALL_URL instead"
	export SERVER_INSTALL_URL="$REPO_URL"
fi
if [ -n "$REQUIREMENTS" ] && [ "$SERVER_REQS_TXT" == "requirements.txt" ]; then
	WARNING "REQUIREMENTS will no longer be used, Use SERVER_REQS_TXT instead"
	export SERVER_REQS_TXT="$REQUIREMENTS"
fi
if [ -n "$CONFIG_FILE" ] && [ "$FRONTEND_SETTINGS_PY" == "auto" ]; then
	WARNING "CONFIG_FILE will no longer be used, Use FRONTEND_SETTINGS_PY instead"
	export FRONTEND_SETTINGS_PY="$CONFIG_FILE"
fi
if [ "$ALLOWED_HOSTS" != "unused" ] && [ -z "$FRONTEND_ALLOWED_HOSTS" ]; then
	WARNING "ALLOWED_HOSTS will no longer be used, Use FRONTEND_ALLOWED_HOSTS instead"
	FRONTEND_ALLOWED_HOSTS="$ALLOWED_HOSTS"
	if [ -z "$ALLOWED_HOSTS" ]; then
		FRONTEND_ALLOWED_HOSTS="container"
	elif [ "${ALLOWED_HOSTS,,}" == "manual" ]; then
		FRONTEND_ALLOWED_HOSTS=""
	fi
	export FRONTEND_ALLOWED_HOSTS
fi
if [ -n "$SYNC_TZ" ] && [ "$FRONTEND_TIME_ZONE" == "TZ" ]; then
	WARNING "SYNC_TZ will no longer be used, Use FRONTEND_TIME_ZONE instead"
	FRONTEND_TIME_ZONE=""
	if [ "$SYNC_TZ" = true ]; then
		FRONTEND_TIME_ZONE="TZ"
	fi
	export FRONTEND_TIME_ZONE
fi
if [ -n "$CUSTOM_UTILS" ] && [ "$BACKEND_CUSTOM_UTILS_PY" = false ]; then
	WARNING "CUSTOM_UTILS will no longer be used, Use BACKEND_CUSTOM_UTILS_PY instead"
	export BACKEND_CUSTOM_UTILS_PY="$CUSTOM_UTILS"
fi



# v1.0.0 to v1.1.0
if [ -n "$PYTHON_VERSION" ] && [ "$SERVER_PYTHON_VERSION" == "3.9.12" ]; then
	WARNING "PYTHON_VERSION will no longer be used, Use SERVER_PYTHON_VERSION instead"
	export SERVER_PYTHON_VERSION="$PYTHON_VERSION"
fi
