#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
# input
## touch event
# output
## touch event when touched by user

while true; do
    "$SCRIPT_DIR"/getevent -l $1 -c 10 | grep -q BTN_TOUCH
    if [[ $? -eq 0 ]]; then
        echo $1
        exit 0
    fi
done
