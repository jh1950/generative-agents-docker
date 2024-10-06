#!/bin/bash

source "/scripts/functions.sh"

cd "$DATA_DIR" || exit 1



# Docker Image Version Check
ACTION "Checking Container Version..."
INFO "Current Version: $IMAGE_VERSION"
if ! [[ "$IMAGE_VERSION" =~ ^v?[0-9]+\.[0-9]+\.[0-9]+ ]]; then
	WARNING "Not a Released Version"
else
	LATEST_VERSION="$(curl -s "https://api.github.com/repos/jh1950/generative-agents-docker/releases/latest" | jq .name -r)"
	INFO "Latest Release: $LATEST_VERSION"
fi
if [ -z "$LATEST_VERSION" ] || ! [[ "$IMAGE_VERSION" =~ ^v?${LATEST_VERSION#v}(-[^0-9])?$ ]]; then
	INFO "How to update: https://github.com/jh1950/generative-agents-docker#이미지-설치"
	INFO "and Restart the Container"
fi



# Python Installation
if [ "$PYENV_ENABLED" = true ]; then
	# pyenv update
	if [ "$PYENV_UPDATE" = true ]; then
		ACTION "Starting pyenv Update"
		pyenv update
	fi

	# Python Install
	ACTION "Starting Python Installation with pyenv"
	INFO "Version: $PYTHON_VERSION"
	if ! pyenv install --list | grep -Eq ^"[[:blank:]]?+$PYTHON_VERSION"$; then
		ERROR "Not found"
		exit 1
	else
		pyenv install "$PYTHON_VERSION"
		pyenv virtualenv "$PYTHON_VERSION" "$VIRTUAL_NAME"
	fi
	pyenv global "$VIRTUAL_NAME"
else
	# VENV Install
	if [ ! -f "$VENV_DIR/.installed" ]; then
		ACTION "Starting VENV Creation"
		python3 -m "$VIRTUAL_NAME" "$VENV_DIR"
	fi
	echo "source $VENV_DIR/bin/activate" >> ~/.bashrc
fi
touch "$VENV_DIR/.installed"

# Python Module Update
if [ ! -f "$REQUIREMENTS_FILE" ]; then
	WARNING "Not found: ${REQUIREMENTS_FILE#/}"
else
	tmp_file="$(mktemp)"
	sha256sum <<< "$(cat "$REQUIREMENTS_FILE")$VIRTUAL_NAME" | awk '{print $1}' > "$tmp_file"
	if ! diff "$VENV_DIR/.installed" "$tmp_file" > /dev/null 2>&1; then
		ACTION "Starting Module Update"
		$PIP install -U pip
		if ! $PIP install -Ur "$REQUIREMENTS_FILE"; then
			ERROR "Update Error"
			exit 1
		fi
		mv "$tmp_file" "$VENV_DIR/.installed"
	fi
fi



# Server Installation
if [ -z "$REPO_URL" ]; then
	IMPORTANT "Use a local files because REPO_URL is not set"
else
	# Repository URL Check
	ACTION "Checking URL..."
	INFO "URL: $REPO_URL"
	status="$(curl -sfSL -o /dev/null -w "%{http_code}" "$REPO_URL")"
	if [ "$status" -ne 200 ]; then
		ERROR "Invalid URL"
		exit 1
	fi

	# Server Install/Update
	if [ ! -d "$DATA_DIR/.git" ]; then
		ACTION "Starting Server Installation"
		git init
		git remote add origin "$REPO_URL"
		git fetch origin main
		git checkout main
	elif [ "$AUTO_UPDATE" = true ]; then
		INSTALLED_URL="$(git config remote.origin.url)"
		INSTALLED_REPO="$(GET_REPO_IN_URL "$INSTALLED_URL")"
		SET_REPO="$(GET_REPO_IN_URL "$REPO_URL")"
		if [ "$INSTALLED_REPO" != "$SET_REPO" ]; then
			INFO "Installed URL: $INSTALLED_URL"
			ERROR "The URL and the installed server do not match, so the update cannot checked."
		else
			ACTION "Checking Update..."
			CURRENT_COMMIT=$(git log HEAD -1 --format=format:%H)
			INFO "Current Version: $CURRENT_COMMIT"
			LATEST_COMMIT=$(curl -sfSL "$REPO_API/commits/main" 2> /dev/null | jq .sha -r)
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
cd "$FRONTEND_DIR" || exit 1
CONFIG_PATH="$(FIND_CONFIG_FILE)"

ACTION "Front-end Setting"
if [ -f "$CONFIG_PATH" ]; then
	INFO "File: ${CONFIG_PATH#/}"
else
	WARNING "Not Found: ${CONFIG_PATH#/}"
fi

if [ "$SYNC_TZ" = true ]; then
	INFO "TIME_ZONE = \"$TZ\""
	DJANGO_CONFIG_SETTING TIME_ZONE "\"$TZ\"" "$CONFIG_PATH"
fi

if [ "$ALLOWED_HOSTS" != "manual" ]; then
	test -z "$ALLOWED_HOSTS" && ALLOWED_HOSTS="$(hostname -i)"
	HOSTS="[$(echo "\"$ALLOWED_HOSTS\"" | sed -E "s/,[[:blank:]]/,/g; s/[[:blank:]],/,/g; s/,,?+/,/g; s/,/\", \"/g")]"
	INFO "ALLOWED_HOSTS = $HOSTS"
	DJANGO_CONFIG_SETTING ALLOWED_HOSTS "$HOSTS" "$CONFIG_PATH"
fi



# Back-end Setting
ACTION "Back-end Setting"
if [ "$CUSTOM_UTILS" = true ]; then
	INFO "Manually copy the utils.py to the ${BACKEND_DIR#/}/utils.py"
else
	INFO "Using built-in utils.py"
	cp /scripts/utils.py "$BACKEND_DIR/utils.py"
fi



# Front-end Start
mkdir -p "$FRONTEND_DIR/"{storage,compressed_storage,temp_storage}
ACTION "Front-end has been Started"
$PYTHON manage.py migrate
$PYTHON manage.py runserver 0.0.0.0:8000
