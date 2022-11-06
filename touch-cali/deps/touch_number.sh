#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
# input
#touch_event="/dev/input/by-path/*usb*-event"
#output
#touch_number=0

#for event in $touch_event
#do
#    if [[ -e "$event" ]];then
#       ((touch_number++))
#    fi
#done
touch_number=$(libinput list-devices | grep -cE "^Capabilities:.*touch")
echo "$touch_number"
exit 0
