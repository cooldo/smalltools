#!/usr/bin/env bash

# full screen qt applications are killed in this script

# kill all qt applications when ctrl c press
trap " \
pkill -f qmlscene; \
pkill -f touch_scan; \
pkill -f getevent; \
pkill -P $$; \
exit 0" 0 1 2

exec 9>/tmp/touch_lock
if ! flock -n 9  ; then
    echo "another instance is running";
    exit 1
fi

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)

export XDG_RUNTIME_DIR=/run/user/root
export QT_WAYLAND_SHELL_INTEGRATION="wl-shell"
# USB already enabled in discovery-init service, so here we delete USB enable
# discovery-init->weston->touch_cali
#echo 0 > /sys/devices/platform/17500000.usb/17500000.dwc3/id
#echo 0 > /sys/devices/platform/17400000.usb/17400000.dwc3/id

if systemctl is-enabled glmark2.service >/dev/null 2>&1; then
    systemctl stop glmark2.service >/dev/null
    systemctl disable glmark2.service >/dev/null
fi

if systemctl is-enabled user-weston-egl-example.service >/dev/null 2>&1; then
    systemctl stop user-weston-egl-example.service >/dev/null
    systemctl disable user-weston-egl-example.service >/dev/null
fi

check_mouse() {
    has_mouse=$("$SCRIPT_DIR"/deps/mouse_detect.sh)
    if [[ "$has_mouse" = "true" ]]; then
        echo "a mouse has deteced, so skip touch calibration"
        echo "run \"/opt/manual-touch/entry.sh\" if you really want to calibrate a specific screen"
        exit 1
    fi
}

touch_dir="/dev/input/by-path/*usb*-event"

# screen startup sequence information should come from weston.log
sort_screen() {
    # if cannot get weston.log, it means screen id cannot get, just exit
    if [[ ! -e /var/log/weston.log ]];then
        echo -e "cannot get your weston.log file,please reboot\nexit" 1>&2
        exit 0
    fi
    rm -f ${SCRIPT_DIR}/.screen.cfg
    rm -f ${SCRIPT_DIR}/.screenTmp.cfg
    sync
    # get screen id
    for screen in /sys/class/drm/card0-*
    do
        if [[ "$(cat "$screen"/status)" == "connected" ]]
        then
            screenid=${screen#*-}
            # get line number of screenid in /val/lig/weston.log
            num=$(awk "/($screenid)/ { print FNR}" /var/log/weston.log  | head -n 1)
            echo "$num" "$screenid" >> ${SCRIPT_DIR}/.screenTmp.cfg
            # if screen1's line number < screen2's line number, it means screen1 start before screen2
        fi
    done
    cut -d" " -f2  <(sort -h ${SCRIPT_DIR}/.screenTmp.cfg) > ${SCRIPT_DIR}/.screen.cfg
}

get_screen_info() {
    local screen_count=0
    screen_count=$(wc -l < ${SCRIPT_DIR}/.screen.cfg)
    echo "$screen_count"
}

get_touch_info() {
    #local event_count=0
    #for event in $touch_dir
    #do
    #   [[ -e $(readlink -f "$event") ]] && ((event_count++))
    #done
    # real touch event should come from libinput
    event_count=$(libinput list-devices | grep -cE "^Capabilities:.*touch")
    echo $event_count
}

check_config() {
    # if screen number is greater than touch number, then exit
    if [[ "$SCREEN_COUNT" -gt "$TOUCH_COUNT" ]];then
        echo "you have $SCREEN_COUNT screens:"
        cat ${SCRIPT_DIR}/.screen.cfg
        echo "but touch num $TOUCH_COUNT don't match:"
        # for debug
        libinput list-devices | grep -E "^Capabilities:.*touch" -B 4 | awk '/^Kernel/ { print $2 }'
        #for event in $touch_dir
        #do
        #    echo "$(readlink -f "$event")"
        #done
        /usr/bin/qmlscene ${SCRIPT_DIR}/deps/err_cali.qml
        has_mouse=$(${SCRIPT_DIR}/deps/mouse_detect.sh)
        if [[ "$has_mouse" == "true" ]];then
            #restart_apps
            exit 0
        else
            # we detect enough touch devices, so go to calibration
            TOUCH_COUNT=$(get_touch_info)
            if [[ "$SCREEN_COUNT" -eq 0 ]]; then
                echo "cannot detect your screen!!!"
                while true
                do
                    sleep 10
                done
            fi
        fi
    fi
}

start_calibration() {
    while true; do
        touch_num=$("$SCRIPT_DIR"/deps/touch_number.sh)

        # start touch calibration in the background
        "$SCRIPT_DIR"/deps/start_cali.sh & PID=$!
        # make sure we started start_cali.sh
        while true; do
            if ! kill -0 "$PID" >/dev/null 2>&1; then
                continue;
            fi
            break
        done
        # In QLA by my test, the event comes very late(20s)
        # W/A: check touch event status(add/remove) periodically
        # when status changed, restart touch calibration
        while true; do
            new_touch_num=$("$SCRIPT_DIR"/deps/touch_number.sh)
            if [[ "$touch_num" -ne "$new_touch_num" ]]; then
                # check if touch_cali.sh exist or not exist
                if ! kill -0 "$PID" >/dev/null 2>&1; then
                    echo "touch abnormal exit, should not be here"
                    return
                fi
                echo "debug touch number has changed, kill $PID, and restart touch-cali"
                # kill touch cliabraion
                kill "$PID"
                # check if touch_cali.sh exist or not exist
                while sleep 1; do
                    if  kill -0 "$PID" >/dev/null 2>&1; then
                        echo "$PID has not be killed, wait 1 more second"
                        continue;
                    fi
                    break
                done
                # this break is very important, it goes back the first loop and restart touch_cali.sh
                break
            else
                if ! kill -0 "$PID" >/dev/null 2>&1; then
                    # touch calibraion process can not found, this means touch calibration has finishied
                    echo "touch normal exit"
                    return
                fi
            fi
        done
    done
}

update_udev_rules() {
    # merge 2 files to 1 file
    paste -d" "  <(cut -d"/" -f4 ${SCRIPT_DIR}/.event.cfg) ${SCRIPT_DIR}/.screen.cfg > ${SCRIPT_DIR}/deps/touch.cfg
    sync
    # generate rules
    echo "##Please wait, generate rules..."
    ${SCRIPT_DIR}/deps/touch-cfg.sh ${SCRIPT_DIR}/deps/touch.cfg
}

# 1) sort screen
sort_screen
# 2) get screen info
SCREEN_COUNT=$(get_screen_info)
# 3) get touch event info
TOUCH_COUNT=$(get_touch_info)
# 4) check mouse
if [[ "touch" != "$1" ]];then
    check_mouse
fi
# 5) stop other fullscreen apps moved to set_apps.sh
# 6) check these info
check_config
sleep 2
# 7) start calibration
start_calibration
# 8) update /etc/dev/rules/multi-touch.rules
update_udev_rules
# 9) configure touch to container
"$SCRIPT_DIR"/deps/container.sh
echo "##Finished"
# 10) restart discovery apps moved to set_apps.sh
exit 0
