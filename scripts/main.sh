#!/bin/bash

source "/scripts/functions.sh"



# Docker Image Version Check
ACTION "Checking Container Version..."
INFO "Current Version of the Container: ${IMAGE_VERSION#v}"
if ! [[ "${IMAGE_VERSION#v}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	WARNING "${IMAGE_VERSION#v} is Unreleased Version"
fi

LATEST_VERSION="$(curl -s "https://api.github.com/repos/jh1950/generative-agents-docker/releases/latest" | jq .name -r)"
if [ "${IMAGE_VERSION#v}" == "${LATEST_VERSION#v}" ]; then
	SUCCESS "Already Up To Date"
else
	IMPORTANT "New Released Version: ${LATEST_VERSION#v}"
	INFO "How to update: docker pull jh1950/generative-agents-docker:latest"
	INFO "               and Restart the Container"
fi



# pyenv Update
ACTION "Checking pyenv Version..."
PYENV_CUR_VERSION="$(pyenv --version)"
INFO "pyenv Version: ${PYENV_CUR_VERSION#* }"
if [ "$PYENV_AUTO_UPDATE" != true ]; then
	INFO "PYENV_AUTO_UPDATE = $PYENV_AUTO_UPDATE"
else
	pyenv update > /dev/null 2>&1
	PYENV_NEW_VERSION="$(pyenv --version)"
	if [ "$PYENV_CUR_VERSION" == "$PYENV_NEW_VERSION" ]; then
		SUCCESS "Already Up To Date"
	else
		SUCCESS "Update Complete: ${PYENV_NEW_VERSION#* }"
	fi
fi

# Python Installation
if [ -n "$SERVER_PYTHON_VERSION" ]; then
	ACTION "Starting Python Installation"
	INFO "SERVER_PYTHON_VERSION = $SERVER_PYTHON_VERSION"
	INSTALL_PYTHON "$SERVER_PYTHON_VERSION" "$SERVER_VIRTUALENV_NAME" || { ERROR "Not found"; exit 1; }
	pyenv global "$SERVER_VIRTUALENV_NAME"
fi
if [ -n "$FRONTEND_PYTHON_VERSION" ]; then
	ACTION "Starting Python Installation (Front-end)"
	INFO "Path: ${FRONTEND_PATH#/}"
	cd "$FRONTEND_PATH" || { ERROR "Not found" ; exit 1; }
	INFO "FRONTEND_PYTHON_VERSION = $FRONTEND_PYTHON_VERSION"
	INSTALL_PYTHON "$FRONTEND_PYTHON_VERSION" "$FRONTEND_VIRTUALENV_NAME" || { ERROR "Not found"; exit 1; }
	pyenv local "$FRONTEND_VIRTUALENV_NAME"
fi
if [ -n "$BACKEND_PYTHON_VERSION" ]; then
	ACTION "Starting Python Installation (Back-end)"
	INFO "Path: ${BACKEND_PATH#/}"
	cd "$BACKEND_PATH" || { ERROR "Not found" ; exit 1; }
	INFO "BACKEND_PYTHON_VERSION = $BACKEND_PYTHON_VERSION"
	INSTALL_PYTHON "$BACKEND_PYTHON_VERSION" "$BACKEND_VIRTUALENV_NAME" || { ERROR "Not found"; exit 1; }
	pyenv local "$BACKEND_VIRTUALENV_NAME"
fi

# Python Modules Update
if [ -n "$SERVER_PYTHON_VERSION" ] && [ -n "$SERVER_REQS_TXT" ]; then
	ACTION "Starting Python Modules Update"
	INFO "Flie: ${SERVER_REQS_PATH#/}"
	FILE_EXISTS "$SERVER_REQS_PATH" || WARNING "Not found"
	INSTALL_PYTHON_MODULES "/" "$SERVER_REQS_PATH" "$SERVER_VIRTUALENV_NAME" || { ERROR "Update Error"; exit 1; }
fi
if [ -n "$FRONTEND_PYTHON_VERSION" ] && [ -n "$FRONTEND_REQS_TXT" ]; then
	ACTION "Starting Python Modules Update (Front-end)"
	INFO "Flie: ${FRONTEND_REQS_PATH#/}"
	FILE_EXISTS "$FRONTEND_REQS_PATH" || WARNING "Not found"
	INSTALL_PYTHON_MODULES "$FRONTEND_PATH" "$FRONTEND_REQS_PATH" "$FRONTEND_VIRTUALENV_NAME" || { ERROR "Update Error"; exit 1; }
fi
if [ -n "$BACKEND_PYTHON_VERSION" ] && [ -n "$BACKEND_REQS_TXT" ]; then
	ACTION "Starting Python Modules Update (Back-end)"
	INFO "Flie: ${BACKEND_REQS_PATH#/}"
	FILE_EXISTS "$BACKEND_REQS_PATH" || WARNING "Not found"
	INSTALL_PYTHON_MODULES "$BACKEND_PATH" "$BACKEND_REQS_PATH" "$BACKEND_VIRTUALENV_NAME" || { ERROR "Update Error"; exit 1; }
fi



# Server Installation/Update
if [ ! -d "$DATA_DIR/.git" ]; then
	ACTION "Starting Server Installation"
else
	ACTION "Starting Server Update"
fi

cd "$DATA_DIR" || exit 1
if [ -z "$SERVER_INSTALL_URL" ]; then
	# Local Server
	IMPORTANT "SERVER_INSTALL_URL is not set"
else
	# Repository URL Check
	INFO "URL: $SERVER_INSTALL_URL"
	status="$(curl -sfSL -o /dev/null -w "%{http_code}" "$SERVER_INSTALL_URL")"
	if [ "$status" -ne 200 ]; then
		ERROR "Invalid URL"
		exit 1
	fi

	if [ ! -d "$DATA_DIR/.git" ]; then
		# Server Installation
		git init
		git remote add origin "$SERVER_INSTALL_URL"
		git fetch origin main
		git checkout main
	elif [ "$SERVER_AUTO_UPDATE" = true ]; then
		# Server Update
		INSTALLED_URL="$(git config remote.origin.url)"
		if [ "$(GET_REPO_IN_URL "$INSTALLED_URL")" != "$(GET_REPO_IN_URL "$SERVER_INSTALL_URL")" ]; then
			INFO "Installed URL: $INSTALLED_URL"
			WARNING "Update Cannot Checked: Server URL Mismatch"
		else
			CURRENT_COMMIT=$(git log HEAD -1 --format=format:%H)
			INFO "Current Version: $CURRENT_COMMIT"
			LATEST_COMMIT=$(curl -sfSL "$GITHUB_API/commits/main" 2> /dev/null | jq .sha -r)
			if [ -z "$LATEST_COMMIT" ]; then
				WARNING "Failed to check latest version"
			elif [ "$CURRENT_COMMIT" != "$LATEST_COMMIT" ]; then
				INFO "Latest Version: $LATEST_COMMIT"
				git stash save "$(date "+%F %T")"
				git fetch origin main
				git pull origin main
			fi
		fi
	fi
fi



# Front-end Setting
cd "$FRONTEND_PATH" || exit 1
SETTINGS_PATH="$(FIND_SETTINGS_PY)"

ACTION "Front-end Setting"
if [ "$FRONTEND_SETTINGS_PY" = false ]; then
	INFO "FRONTEND_SETTINGS_PY = \"\""
else
	if ! FILE_EXISTS "$SETTINGS_PATH"; then
		ERROR "Not Found: ${SETTINGS_PATH#/}"
	else
		INFO "File: ${SETTINGS_PATH#/}"

		if [ -n "$FRONTEND_ALLOWED_HOSTS" ]; then
			test "${FRONTEND_ALLOWED_HOSTS,,}" == "container" && FRONTEND_ALLOWED_HOSTS="$(hostname -I | tr " " ",")"
			ALLOWED_HOSTS="[$(echo "\"$FRONTEND_ALLOWED_HOSTS\"" | sed -E "s/,[[:blank:]]/,/g; s/[[:blank:]],/,/g; s/,,?+/,/g; s/,\"/\"/g; s/\",/\"/g; s/,/\", \"/g")]"
			INFO "ALLOWED_HOSTS = $ALLOWED_HOSTS"
			DJANGO_SETTING_CHANGE ALLOWED_HOSTS "$ALLOWED_HOSTS" "$SETTINGS_PATH"
		fi

		if [ -n "$FRONTEND_TIME_ZONE" ]; then
			TMP="$FRONTEND_TIME_ZONE"
			if [ "${FRONTEND_TIME_ZONE,,}" == "tz" ]; then
				TMP="$TZ"
			fi
			INFO "TIME_ZONE = \"$TMP\""
			DJANGO_SETTING_CHANGE TIME_ZONE "\"$TMP\"" "$SETTINGS_PATH"
		fi
	fi
fi



# Back-end Setting
ACTION "Back-end Setting"
if [ "$BACKEND_CUSTOM_UTILS_PY" = true ]; then
	INFO "Manually copy the utils.py to the ${BACKEND_PATH#/}/utils.py"
else
	INFO "Using built-in utils.py"
	cp /scripts/utils.py "$BACKEND_PATH/utils.py"
fi



# Front-end Start
mkdir -p {storage,compressed_storage,temp_storage}
ACTION "Front-end has been Started"
$PYTHON manage.py migrate
$PYTHON manage.py runserver 0.0.0.0:8000
