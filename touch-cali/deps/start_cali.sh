#!/usr/bin/env bash
trap " \
pkill -f qmlscene; \
pkill -f touch_scan; \
pkill -f getevent; \
pkill -P $$; \
exit 0" 0 1 2

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
export XDG_RUNTIME_DIR=/run/user/root
export QT_WAYLAND_SHELL_INTEGRATION="wl-shell"
SCREEN_COUNT=$("$SCRIPT_DIR"/screen_number.sh)


    rm -rf ${SCRIPT_DIR}/../.event.cfg
    touch ${SCRIPT_DIR}/../.event.cfg
    sync
    while read realevent
    do
        ( ${SCRIPT_DIR}/touch_scan.sh "$realevent" >> ${SCRIPT_DIR}/../.event.cfg & )
    done < <(libinput list-devices | grep -E "^Capabilities:.*touch" -B 4 | awk '/^Kernel/ { print $2 }')


    (/usr/bin/qmlscene ${SCRIPT_DIR}/need_cali.qml 2>/dev/null  &)
    count=0
    while read event
    do
        # if .event.cfg is updated by touch_event
        ((count++))
        # show already calibrated screen
        echo "screen $count is ready"
        sed -n ""$count"p" ${SCRIPT_DIR}/../.event.cfg
        sed -n ""$count"p" ${SCRIPT_DIR}/../.screen.cfg
        #  1) kill need_cali qml
        pkill -f need_cali
        # make sure it kills succesfully
        if [[ $? -eq 0 ]];then
            sleep 0.5
            # 2) start a new qml in the orginal screen
            (/usr/bin/qmlscene ${SCRIPT_DIR}/ok_cali.qml 2>/dev/null &)
            sleep 1
            # if all the screens filled, then break;
            if [[ $count -eq $SCREEN_COUNT ]];then
                    break
            fi
            # 3) else start a new qml in next screen
            (/usr/bin/qmlscene ${SCRIPT_DIR}/need_cali.qml 2>/dev/null &)
        fi
    done < <(tail -f "${SCRIPT_DIR}"/../.event.cfg)
