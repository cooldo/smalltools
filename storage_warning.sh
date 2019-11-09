#!/bin/bash

show_usage() {
    echo "Usage: $0 <percentage>"
    echo "put into crontab:"
    echo "@hourly $0 <percentage>"
    exit 1
}

STORAGE="sda10"

notify_user() {
    #TTY=$(who | tr -s ' '  | cut -d' ' -f 2)
    # better way
    TTY=$(who | awk '{ print $2 }')
    for tty in $TTY
    do
        echo -e "\033[31m "$1"\033[0m" > "/dev/$tty"
    done
}

if [[ $# -ne 1 ]];then
    show_usage
fi

#PERCENTAGE=$(df | sed -n "/"$STORAGE"/p" | tr -s ' ' | cut -d' ' -f 5)
# best way
#PERCENTAGE=$(df | awk '{ if($1 ~ /sda10/)  print $5 }')
# better way
PERCENTAGE=$(df | awk '/sda10/ { print $5 }')
# awk usage
# awk '/[0-9]/ { print }
# awk '/[0-9]$/ { print }
# awk '/^[0-9]/ { print }
# awk -F: '/^[0-9]/ { print }

NUMBER=${PERCENTAGE%\%*}
echo $NUMBER

if [[ "$NUMBER" -gt $1 ]];then
    notify_user "STORAGE FULL $NUMBER%"
fi

