#!/bin/bash

source "/scripts/functions.sh"


# Repository URL Check
ACTION "URL Checking..."
INFO "URL: $REPO_URL"
status="$(curl -sfSL -o /dev/null -w "%{http_code}" "$REPO_URL")"
if [ "$status" -ne 200 ]; then
	ERROR "URL Not found"
	exit 1
fi


# Server Install
if [ ! -d "$DATA_DIR/.git" ]; then
	cd "$DATA_DIR" || exit 1
	ACTION "Starting Server Installation"
	git init
	git remote add origin "$REPO_URL"
	git fetch origin main
	git checkout main
fi


# VENV Install
if [ ! -d "$VENV_DIR/bin" ]; then
	ACTION "Starting VENV Creation"
	python3 -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
echo "source $VENV_DIR/bin/activate" >> ~/.bashrc


# VENV Module Update
SHASUM="$(cat "$VENV_DIR/.installed" 2> /dev/null)"
if ! echo "$SHASUM" "$DATA_DIR/requirements.txt" | sha256sum -c - > /dev/null 2>&1; then
	ACTION "Starting Module Update"
	pip install -U pip
	if ! pip install -Ur "$DATA_DIR/requirements.txt"; then
		ERROR "Update Error"
		exit 1
	fi
	sha256sum "$DATA_DIR/requirements.txt" | awk '{print $1}' > "$VENV_DIR/.installed"
fi


cd "$FRONTEND_DIR" || exit 1

# Server Setting
if [ "$ALLOWED_HOSTS" != "manual" ]; then
	ACTION "Change Setting"
	test -z "$ALLOWED_HOSTS" && ALLOWED_HOSTS="$(hostname -i)"
	HOSTS="ALLOWED_HOSTS = [$(echo "\"$ALLOWED_HOSTS\"" | sed -E "s/,[[:blank:]]/,/g; s/[[:blank:]],/,/g; s/,,?+/,/g; s/,/\", \"/g")]"
	INFO "$HOSTS"
	sed -i "s/^ALLOWED_HOSTS.*/$HOSTS/g" "$CONFIG_FILE"
fi

# Server Start
mkdir -p "$FRONTEND_DIR/"{storage,compressed_storage,temp_storage}
ACTION "Server has been Started"
python3 manage.py migrate
python3 manage.py runserver 0.0.0.0:8000
