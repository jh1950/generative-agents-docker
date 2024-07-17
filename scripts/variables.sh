#!/bin/bash

export DATA_DIR="/data"
export VENV_DIR="$DATA_DIR/venv"

export REPO_URL="https://github.com/jh1950/generative_agents"
export REPO_API="${REPO_URL/github\.com/api.github.com\/repos}"
export FRONTEND_DIR="$DATA_DIR/environment/frontend_server"
export BACKEND_DIR="$DATA_DIR/reverie/backend_server"
export CONFIG_FILE="$FRONTEND_DIR/config/settings/local.py"
