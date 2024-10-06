#!/bin/bash

export PYTHON_VERSION="${PYTHON_VERSION:-"3.9.12"}"
if [ "$PYENV_ENABLED" = true ]; then
	VENV_DIR="pyenv-versions"
	PYTHON_BIN="$PYENV_ROOT/shims"
	VIRTUAL_NAME="pyenv-$PYTHON_VERSION"
else
	VENV_DIR="venv"
	PYTHON_BIN="$DATA_DIR/$VENV_DIR/bin"
	VIRTUAL_NAME="venv"
fi
export VIRTUAL_NAME
export VENV_DIR="$DATA_DIR/$VENV_DIR"
export PYTHON="$PYTHON_BIN/python3"
export PIP="$PYTHON_BIN/pip3"

export REPO_API="${REPO_URL/github\.com/api.github.com\/repos}"
export REQUIREMENTS_FILE="$DATA_DIR/$REQUIREMENTS"
export FRONTEND_DIR="$DATA_DIR/$FRONTEND_ROOT"
export BACKEND_DIR="$DATA_DIR/$BACKEND_ROOT"
