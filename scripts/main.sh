#!/bin/bash

source "/scripts/functions.sh"


# Docker Image Version Check
if [ "$IMAGE_VERSION" == "dev" ]; then
	WARNING "The container is using the dev version"
else
	LATEST_VERSION=$(curl "$REPO_API/releases/latest" -s | jq .name -r)
	if [ "${IMAGE_VERSION#v}" != "${LATEST_VERSION#v}" ]; then
		IMPORTANT "Latest Release: $LATEST_VERSION"
	fi
fi
if [ -z "$LATEST_VERSION" ] || [ "${IMAGE_VERSION#v}" != "${LATEST_VERSION#v}" ]; then
	INFO "Run: docker pull jh1950/generative-agents-docker:latest"
	INFO "And Restarting the Container"
fi


if [ -z "$REPO_URL" ]; then
	ACTION "Use a local files because REPO_URL is not set"
else
	# Repository URL Check
	ACTION "URL Checking..."
	INFO "URL: $REPO_URL"
	status="$(curl -sfSL -o /dev/null -w "%{http_code}" "$REPO_URL")"
	if [ "$status" -ne 200 ]; then
		ERROR "Invalid URL: $REPO_URL"
		exit 1
	fi
fi


cd "$DATA_DIR" || exit 1
if [ -n "$REPO_URL" ]; then
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
			CURRENT_COMMIT=$(git log HEAD -1 --format=format:%H)
			LATEST_COMMIT=$(curl -sfSL "$REPO_API/commits/main" | jq .sha -r)
			if [ "$CURRENT_COMMIT" != "$LATEST_COMMIT" ]; then
				ACTION "Starting Server Update"
				git stash save "$(date "+%F %T")"
				git fetch origin main
				git pull origin main
			fi
		fi
	fi
fi


# VENV Install
if [ ! -f "$VENV_DIR/.installed" ]; then
	ACTION "Starting VENV Creation"
	python3 -m venv "$VENV_DIR"
fi
touch "$VENV_DIR/.installed"
echo "source $VENV_DIR/bin/activate" >> ~/.bashrc


# VENV Module Update
SHASUM="$(cat "$VENV_DIR/.installed")"
if ! echo "$SHASUM" "$REQUIREMENTS_FILE" | sha256sum -c - > /dev/null 2>&1; then
	ACTION "Starting Module Update"
	$PIP install -U pip
	if ! $PIP install -Ur "$REQUIREMENTS_FILE"; then
		ERROR "Update Error"
		exit 1
	fi
	sha256sum "$REQUIREMENTS_FILE" | awk '{print $1}' > "$VENV_DIR/.installed"
fi


# Server Setting
cd "$FRONTEND_DIR" || exit 1

if [ "$SYNC_TZ" = true ]; then
	DJANGO_CONFIG_SETTING TIME_ZONE "\"$TZ\""
fi

if [ "$ALLOWED_HOSTS" != "manual" ]; then
	ACTION "Change Setting"
	test -z "$ALLOWED_HOSTS" && ALLOWED_HOSTS="$(hostname -i)"
	HOSTS="[$(echo "\"$ALLOWED_HOSTS\"" | sed -E "s/,[[:blank:]]/,/g; s/[[:blank:]],/,/g; s/,,?+/,/g; s/,/\", \"/g")]"
	INFO "ALLOWED_HOSTS = $HOSTS"
	DJANGO_CONFIG_SETTING ALLOWED_HOSTS "$HOSTS"
fi

if [ "$CUSTOM_UTILS" = false ]; then
	cp /scripts/utils.py "$BACKEND_DIR/utils.py"
fi


# Front-end Start
mkdir -p "$FRONTEND_DIR/"{storage,compressed_storage,temp_storage}
ACTION "Front-end has been Started"
$PYTHON manage.py migrate
$PYTHON manage.py runserver 0.0.0.0:8000
