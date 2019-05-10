#!/bin/bash

show_usage() {
    echo "Usage: $0 <percentage>"
    echo "put into crontab:"
    echo "@hourly $0 <percentage>"
    exit 1
}


if [[ $# -ne 1 ]];then
    show_usage
fi

PERCENTAGE=$(df | sed -n "/sda9/p" | tr -s ' ' | cut -d' ' -f 5)
NUMBER=${PERCENTAGE%\%*}

notify_user() {
    TTY=$(who | tr -s ' '  | cut -d' ' -f 2)
    for tty in $TTY
    do
        echo -e "\033[31m ${1}\033[0m" > "/dev/$tty"
    done
}

if [[ $NUMBER -gt $1 ]];then
    notify_user "STORAGE FULL $NUMBER%"
fi

