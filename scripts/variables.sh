#!/bin/bash

export PYTHON_VERSION="${PYTHON_VERSION:-"3.9.12"}"
export VIRTUALENV_NAME="Python-$PYTHON_VERSION"
export PYENV_VERSIONS_SAVE_PATH="$DATA_DIR/$PYENV_VERSIONS_SAVE_ROOT"
export PYTHON="$PYENV_ROOT/shims/python3"
export PIP="$PYENV_ROOT/shims/pip3"

export GITHUB_API="${SERVER_INSTALL_URL/github\.com/api.github.com\/repos}"

export SERVER_REQS_PATH="$DATA_DIR/$SERVER_REQS_TXT"
export FRONTEND_PATH="$DATA_DIR/$FRONTEND_ROOT"
export BACKEND_PATH="$DATA_DIR/$BACKEND_ROOT"
