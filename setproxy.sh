#!/bin/bash

show_usage() {
    echo "Usage: source $0  <start | stop>"
}

GOTO=0
if [[ $# -ne 1 ]]; then
    show_uage
    GOTO=1
fi

if [[ "$GOTO" -eq 0 ]];then
    case $1 in
    "start")
        unset http_proxy https_proxy
        unset HTTP_PROXY HTTPS_PROXY
        # start socks5 proxy(should provide sslocal.service)
        systemctl restart sslocal
        # start http --> socks5 proxy
        # rederect socks:1080 --> http:8118
        # (forward-socks5t   / 127.0.0.1:1080 .)
        systemctl restart privoxy
        export http_proxy=http://127.0.0.1:8118/
        export https_proxy=https://127.0.0.1:8118/
        ;;
    "stop")
        systemctl stop sslocal
        systemctl stop privoxy
        #export http_proxy=http://109.105.113.200:8080
        #export https_proxy=https://109.105.113.200:8080
        ;;
    *)
        echo "parameter error"
        ;;
    esac
fi
