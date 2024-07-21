#!/bin/bash

export DATA_DIR="/data"
export VENV_DIR="$DATA_DIR/venv"

export REPO_API="${REPO_URL/github\.com/api.github.com\/repos}"
export FRONTEND_DIR="$DATA_DIR/$FRONTEND_ROOT"
export BACKEND_DIR="$DATA_DIR/$BACKEND_ROOT"
