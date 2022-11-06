#!/usr/bin/env bash
SERVICE_LIST=(app2 app1 app3 rse rse2 app6 sfi_telltale)
clean_other_apps() {
    # kill all the other qt process
    echo "##kill all qt process, please wait..."
    for item in ${SERVICE_LIST[@]}
    do
        # only when app is running(active), we nned to stop it
        if systemctl is-active discovery_"$item";then
            systemctl stop discovery_"$item" 2>/dev/null
        fi
    done

    # for sfi_telltale.service, it is not enough to stop its service
    # I need to manually exec the following command to stop it totally
    sficli telltale end 2>/dev/null
}

restart_apps() {
    # should kill qmlscene applications before start discovery applications
    pkill qmlscene
    while sleep 1;do
        if  ! pgrep qmlscene; then
            break
        fi
    done
    echo "##start all qt process, please wait..."
    for item in ${SERVICE_LIST[@]}
    do
        # only when app is not running(inactive), we nned to restart it
        if ! systemctl is-active discovery_"$item";then
            systemctl restart discovery_"$item" 2>/dev/null &
        fi
    done
}

if [[ "$1" = "stop" ]];then
    clean_other_apps
elif [[ "$1" = "restart" ]];then
    restart_apps
fi
