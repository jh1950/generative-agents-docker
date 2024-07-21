#!/bin/bash

source "/scripts/variables.sh"


mode="${1,,}"
if [ "$EUID" -eq 0 ]; then
    root=true
else
    root=false
fi


run() {
    if [ "$root" = true ]; then
        su user -c "$@"
    else
        "$@"
    fi
}


case "$mode" in
    "shell")
        if [ "$root" = true ]; then
            su user -s /bin/bash
        else
            /bin/bash
        fi
        ;;
    "venv|django-shell")
        run "$VENV_DIR/bin/python3" "$FRONTEND_DIR/manage.py" shell
        ;;
    *)
        echo "Usage: connect [shell|venv|django]"
        ;;
esac
