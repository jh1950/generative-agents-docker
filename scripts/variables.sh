#!/bin/bash

export DATA_DIR="/data"
export VENV_DIR="$DATA_DIR/venv"
export PYTHON="$VENV_DIR/bin/python3"
export PIP="$VENV_DIR/bin/pip3"

export REPO_API="https://api.github.com/repos/jh1950/generative-agents-docker"
export REQUIREMENTS_FILE="$DATA_DIR/$REQUIREMENTS"
export FRONTEND_DIR="$DATA_DIR/$FRONTEND_ROOT"
export BACKEND_DIR="$DATA_DIR/$BACKEND_ROOT"
