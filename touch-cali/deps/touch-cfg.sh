#!/bin/bash
# by qiang1.gao(2018/12/24)

show_usage() {
    echo "Usage: $0 ./touch.cfg"
    echo "touch.cfg should be paired with {eventid screenid}, ex, event1 DSI-1"
    exit 1
}

if [ $# -ne 1 ]; then
    show_usage
fi

exec 0<$1
# if rules don't exist, then create one
if [[ ! -e /etc/udev/rules.d/multi-touch.rules ]];then
        touch /etc/udev/rules.d/multi-touch.rules
fi

sed -i "s/^#//" /etc/udev/rules.d/multi-touch.rules || exit -1
sed -i "s/^/#/" /etc/udev/rules.d/multi-touch.rules || exit -1
sync
while read line; do
    arr=($line)
    event=${arr[0]}
    screen=${arr[1]}

    #echo "before" $line
    # check what we get in the file of touch.cfg
    echo "$line" | grep "\#" > /dev/null
    if [ $? -eq 0 ]; then
      continue
    fi
    echo "$event" | grep "event" > /dev/null
    if [ $? -ne 0 ]; then
      continue
    fi
    devpath=$(udevadm info -a -p $(udevadm info -q path -n /dev/input/$event) | grep -i ATTRS{devpath} | head -n 1)
    shopt -s extglob
    devpath=${devpath##*( )}   # trim the left
    if [ -z "$devpath" ]; then
        echo "cannot find $event or have not configured multitouch"
        exit 0
    fi
    echo "# $event " >> /etc/udev/rules.d/multi-touch.rules
    sync
    echo "$devpath,ENV{WL_OUTPUT}=\"$screen\"" >> /etc/udev/rules.d/multi-touch.rules
    sync
done
sync
#update touch rule
if [[ -e /sys/devices/platform/17400000.usb/id ]];then
    udevadm trigger --type=devices --action=remove --parent-match=/sys/devices/platform/17400000.usb
fi
if [[ -e /sys/devices/platform/17500000.usb/id ]];then
    udevadm trigger --type=devices --action=remove --parent-match=/sys/devices/platform/17500000.usb
fi
udevadm control --reload-rules
sync
if [[ -e /sys/devices/platform/17400000.usb/id ]];then
    udevadm trigger --type=devices --action=add --parent-match=/sys/devices/platform/17400000.usb
fi
if [[ -e /sys/devices/platform/17500000.usb/id ]];then
    udevadm trigger --type=devices --action=add --parent-match=/sys/devices/platform/17500000.usb
fi

