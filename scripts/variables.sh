#!/bin/bash

export PYTHON="$PYENV_ROOT/shims/python3"
export PIP="$PYENV_ROOT/shims/pip3"
export PYENV_VERSIONS="$PYENV_ROOT/versions"
export GITHUB_API="${SERVER_INSTALL_URL/github\.com/api.github.com\/repos}"

export SERVER_VIRTUALENV_NAME="Python-$SERVER_PYTHON_VERSION"
export SERVER_REQS_PATH="$DATA_DIR/$SERVER_REQS_TXT"
export SERVER_PYTHON="$PYENV_VERSIONS/$SERVER_VIRTUALENV_NAME/bin/python3"
export SERVER_PIP="$PYENV_VERSIONS/$SERVER_VIRTUALENV_NAME/bin/pip3"

export FRONTEND_PATH="$DATA_DIR/$FRONTEND_ROOT"
export FRONTEND_VIRTUALENV_NAME="frontend-$FRONTEND_PYTHON_VERSION"
export FRONTEND_REQS_PATH="$FRONTEND_PATH/$FRONTEND_REQS_TXT"
TMP="$SERVER_VIRTUALENV_NAME"
if [ -n "$FRONTEND_PYTHON_VERSION" ]; then
	TMP="$FRONTEND_VIRTUALENV_NAME"
fi
export FRONTEND_PYTHON="$PYENV_VERSIONS/$TMP/bin/python3"
export FRONTEND_PIP="$PYENV_VERSIONS/$TMP/bin/pip3"

export BACKEND_PATH="$DATA_DIR/$BACKEND_ROOT"
export BACKEND_VIRTUALENV_NAME="backend-$BACKEND_PYTHON_VERSION"
export BACKEND_REQS_PATH="$BACKEND_PATH/$BACKEND_REQS_TXT"
TMP="$SERVER_VIRTUALENV_NAME"
if [ -n "$BACKEND_PYTHON_VERSION" ]; then
	TMP="$BACKEND_VIRTUALENV_NAME"
fi
export BACKEND_PYTHON="$PYENV_VERSIONS/$TMP/bin/python3"
export BACKEND_PIP="$PYENV_VERSIONS/$TMP/bin/pip3"



TMP="$SERVER_VIRTUALENV_NAME"
if [ "$FRONTEND_PYTHON_VERSION" ]; then
	TMP="$FRONTEND_VIRTUALENV_NAME"
fi
export GLOBAL_VIRTUALENV_NAME="$TMP"
