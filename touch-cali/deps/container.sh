#!/usr/bin/env bash
SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

#input
touch_cfg_file="/etc/udev/rules.d/multi-touch.rules"
#output
container_cfg_dir="/var/lib/lxc"

# Bare relation
screen_name_array=(HDMI-A-1 HDMI-A-2 DP-3 DP-4 DP-6 DP-7)
wod_name_array=(card1 card2 card3 card4 card5 card6)

# QL relation
#screen_name_array=(DP-6 DP-7)
#wod_name_array=(card4 card3)


screen_array_num="${#screen_name_array[@]}"
let screen_array_num="$screen_array_num"-1

declare -A MAP
for i in $(seq 0 $screen_array_num)
do
    MAP["${wod_name_array[$i]}"]="${screen_name_array[$i]}"
done

# input
# $1 screen_name
# output
# event_name
get_event_name()
{
    while IFS= read -r line;do
        if [[ ${line:0:1} == "#" ]];then
            #echo "this line is commented: $line"
            continue
        fi

        if echo $line | grep $1 >/dev/null 2>&1; then
            #echo "debug $1 exists in $line"
            echo $line | grep -o -E event[0-9]+
            return
        fi
    done < "$touch_cfg_file"
}

for config in "$container_cfg_dir"/android*/config
do
    #echo $config
    if [[ -e "$config" ]];then
        card=$(grep -o -m1 card[1-6] "$config")
        #echo "$card"
        if [[ "$card" == "" ]];then
            echo "cannot file card in file $config; exit"
            exit 0
        fi
    fi
    screen_name=${MAP["$card"]}
    #echo $screen_name
    event=$(get_event_name $screen_name)
    if [[ "$event" =~ event[0-9]+ ]];then
        sed -i "s/event[0-9]\+/$event/" $config
        echo "set $event to $config"
        sed -n "/event/p" $config
    else
        echo "###############"
        echo "cannot find matched event for $config"
        echo "card  : $card"
        echo "screen: $screen_name"
        echo "event : $event"
        echo "###############"
        continue
    fi
done
