#!/bin/bash

source "/scripts/functions.sh"

cd "$DATA_DIR" || exit 1



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
ACTION "Starting Python Installation"
INFO "PYTHON_VERSION = $PYTHON_VERSION"
if ! pyenv install --list | grep -Eq ^"[[:blank:]]?+$PYTHON_VERSION"$; then
	ERROR "Not found"
	exit 1
else
	pyenv install "$PYTHON_VERSION"
	pyenv virtualenv "$PYTHON_VERSION" "$VIRTUALENV_NAME"
fi
pyenv global "$VIRTUALENV_NAME"
touch "$PYENV_VERSIONS_SAVE_PATH/.installed"



# Server Installation/Update
if [ ! -d "$DATA_DIR/.git" ]; then
	ACTION "Starting Server Installation"
else
	ACTION "Starting Server Update"
fi
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



# Python Modules Update
ACTION "Starting Python Modules Update"
if [ -z "$SERVER_REQS_TXT" ]; then
	INFO "SERVER_REQS_TXT = \"\""
else
	INFO "File: ${SERVER_REQS_PATH#/}"
	if [ ! -f "$SERVER_REQS_PATH" ]; then
		WARNING "Not found"
	else
		tmp_file="$(mktemp)"
		sha256sum <<< "$(cat "$SERVER_REQS_PATH")$VIRTUALENV_NAME" | awk '{print $1}' > "$tmp_file"
		if diff "$PYENV_VERSIONS_SAVE_PATH/.installed" "$tmp_file" > /dev/null 2>&1; then
			SUCCESS "Already Up To Date"
		else
			$PIP install -U pip
			if ! $PIP install -Ur "$SERVER_REQS_PATH"; then
				ERROR "Update Error"
				exit 1
			fi
			mv "$tmp_file" "$PYENV_VERSIONS_SAVE_PATH/.installed"
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
	if [ ! -f "$SETTINGS_PATH" ]; then
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
mkdir -p "$FRONTEND_PATH/"{storage,compressed_storage,temp_storage}
ACTION "Front-end has been Started"
$PYTHON manage.py migrate
$PYTHON manage.py runserver 0.0.0.0:8000
