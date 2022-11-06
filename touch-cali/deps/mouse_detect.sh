#!/usr/bin/env bash
# for some kind of monitors, it enums 2 input devices as below, one is touch event, the other is mouse event
# obviously, we should exclude this mouse device when do the mouse detection
# we need to exclude the following mouse
# lrwxrwxrwx 1 root root   9 Dec  1 00:00 platform-xhci-hcd.8.auto-usb-0:1.1.4:1.0-event -> ../event2
# lrwxrwxrwx 1 root root   9 Dec  1 00:00 platform-xhci-hcd.8.auto-usb-0:1.1.4:1.1-event-mouse -> ../event3

touch_dir="/dev/input/by-path/*usb*-event-mouse"
for event_mouse in $touch_dir
do
    if [[ -e "$event_mouse" ]]; then
        event_mouse=${event_mouse%.*}
        if ! ls "$event_mouse"*-event >/dev/null 2>&1; then
            echo true
            exit 0
        fi
    fi
done

# for wirless mouse, there's no event-mouse in /dev/input/ directory.
# add wireless mouse rule (grep -c means count)
mouse_num=$(libinput list-devices | grep  "^Device:" | grep -c "2.4G Keyboard Mouse")
if [[ "$mouse_num" -gt 0 ]];then
    echo true
    exit 0
fi

echo false
