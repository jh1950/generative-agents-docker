#!/bin/bash

export PYTHON="$PYENV_ROOT/shims/python3"
export PIP="$PYENV_ROOT/shims/pip3"
export PYENV_VERSIONS_SAVE_PATH="$DATA_DIR/$PYENV_VERSIONS_SAVE_ROOT"
export GITHUB_API="${SERVER_INSTALL_URL/github\.com/api.github.com\/repos}"

export SERVER_VIRTUALENV_NAME="Python-$SERVER_PYTHON_VERSION"
export SERVER_REQS_PATH="$DATA_DIR/$SERVER_REQS_TXT"

export FRONTEND_PATH="$DATA_DIR/$FRONTEND_ROOT"
export FRONTEND_VIRTUALENV_NAME="frontend-$FRONTEND_PYTHON_VERSION"
export FRONTEND_REQS_PATH="$FRONTEND_PATH/$FRONTEND_REQS_TXT"

export BACKEND_PATH="$DATA_DIR/$BACKEND_ROOT"
export BACKEND_VIRTUALENV_NAME="backend-$BACKEND_PYTHON_VERSION"
export BACKEND_REQS_PATH="$BACKEND_PATH/$BACKEND_REQS_TXT"
