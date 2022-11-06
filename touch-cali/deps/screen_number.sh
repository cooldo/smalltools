#!/usr/bin/env bash
# input
screen_status="/sys/class/drm/card0-*/status"
# output
screen_number=0

for status in $screen_status
do
    if [[ "$(cat "$status")" == "connected" ]]; then
        ((screen_number++))
    fi
done
echo "$screen_number"
exit 0
