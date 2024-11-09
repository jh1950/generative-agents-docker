#!/bin/bash

source "/scripts/functions.sh"



# Docker Image Version Check
if [ "$DOCKER_VERSION_CHECK" != false ]; then
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
fi



# Server Installation/Update
if [ -z "$SERVER_INSTALL_URL" ]; then
	# Local Server
	IMPORTANT "SERVER_INSTALL_URL is not set"
else
	cd "$DATA_DIR" || exit 1

	# Repository URL Check
	ACTION "Checking URL..."
	INFO "SERVER_INSTALL_URL = $SERVER_INSTALL_URL"
	status="$(curl -sfSL -o /dev/null -w "%{http_code}" "$SERVER_INSTALL_URL")"
	if [ "$status" -ne 200 ]; then
		ERROR "Invalid URL"
		exit 1
	fi

	if [ ! -d "$DATA_DIR/.git" ]; then
		# Server Installation
		ACTION "Starting Server Installation"
		git init
		git remote add origin "$SERVER_INSTALL_URL"
		git fetch origin main
		git checkout main
	elif [ "$SERVER_AUTO_UPDATE" = true ]; then
		# Server Update
		ACTION "Starting Server Update"
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



if [ "$PYENV_AWAIT_INSTALL" = true ]; then
	IMPORTANT "PYENV_AWAIT_INSTALL = true"
	if ! DIR_EXISTS "$PYENV_VERSIONS"; then
		INFO "Waiting for pyenv to be installed..."
		while ! DIR_EXISTS "$PYENV_VERSIONS"; do
			sleep 3s
		done
	fi
else
	if ! which pyenv > /dev/null; then
		# pyenv Installation
		ACTION "Starting pyenv Installation"
		curl -sfSL https://pyenv.run | bash
		pyenv update
		eval "$(pyenv init -)"
		SUCCESS "pyenv Version: $(pyenv --version)"
	elif [ "$PYENV_AUTO_UPDATE" == true ]; then
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
	fi
fi
echo -e "eval \"\$(pyenv init -)\"\neval \"\$(pyenv virtualenv-init -)\"" >> "/home/$USER/.bashrc"

F_TMP() {
	local PREFIX="$1"
	local DIR="$2"
	local PYTHON_VERSION="$3"
	local REQS_PATH="$4"
	local VIRTUALENV_NAME="$5"
	local PYTHON_AWAIT_INSTALL="$6"
	local LOCKFILE="$PYENV_VERSIONS/$VIRTUALENV_NAME.lock"
	# Delete LOCKFILE when modules installed ready

	if [ -n "$PYTHON_VERSION" ] && { [ "$PYENV_AWAIT_INSTALL" = true ] || [ "$PYTHON_AWAIT_INSTALL" = true ]; } then
		IMPORTANT "PYENV_AWAIT_INSTALL or ${PREFIX}PYTHON_AWAIT_INSTALL = true"
		if ! DIR_EXISTS "$PYENV_VERSIONS/$VIRTUALENV_NAME" || FILE_EXISTS "$LOCKFILE"; then
			touch "$LOCKFILE"
			INFO "Waiting for $VIRTUALENV_NAME to be installed..."
			while FILE_EXISTS "$LOCKFILE"; do
				sleep 3s
			done
		fi
	else
		touch "$LOCKFILE"
		# Python Installation
		if [ -n "$PYTHON_VERSION" ]; then
			ACTION "Starting Python Installation"
			INFO "Path: ${DIR#/}"
			cd "$DIR" || { ERROR "Not found" ; exit 1; }
			INFO "${PREFIX}PYTHON_VERSION = $PYTHON_VERSION"
			INSTALL_PYTHON "$PYTHON_VERSION" "$VIRTUALENV_NAME" || { ERROR "Not found"; exit 1; }
		fi

		# Python Modules Update
		if [ -n "$PYTHON_VERSION" ] && [ -n "$REQS_PATH" ]; then
			ACTION "Starting Python Modules Update"
			INFO "Flie: ${REQS_PATH#/}"
			FILE_EXISTS "$REQS_PATH" || WARNING "Not found"
			INSTALL_PYTHON_MODULES "$DIR" "$REQS_PATH" "$VIRTUALENV_NAME" || { ERROR "Update Error"; exit 1; }
		fi
		rm -f "$LOCKFILE"
	fi
}
F_TMP "SERVER_" "$DATA_DIR" "$SERVER_PYTHON_VERSION" "$SERVER_REQS_PATH" "$SERVER_VIRTUALENV_NAME" "$SERVER_PYTHON_AWAIT_INSTALL"
F_TMP "FRONTEND_" "$FRONTEND_PATH" "$FRONTEND_PYTHON_VERSION" "$FRONTEND_REQS_PATH" "$FRONTEND_VIRTUALENV_NAME" "$FRONTEND_PYTHON_AWAIT_INSTALL"
F_TMP "BACKEND_" "$BACKEND_PATH" "$BACKEND_PYTHON_VERSION" "$BACKEND_REQS_PATH" "$BACKEND_VIRTUALENV_NAME" "$BACKEND_PYTHON_AWAIT_INSTALL"
pyenv global "$GLOBAL_VIRTUALENV_NAME"



# Front-end Setting
if [ "$FRONTEND_SETTINGS_PY" = false ]; then
	INFO "FRONTEND_SETTINGS_PY = \"\""
else
	cd "$FRONTEND_PATH" || exit 1
	ACTION "Front-end Setting"
	SETTINGS_PATH="$(FIND_SETTINGS_PY)"
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
$FRONTEND_PYTHON manage.py migrate
$FRONTEND_PYTHON manage.py runserver 0.0.0.0:8000
