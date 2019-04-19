#!/bin/bash
trap 'echo "##user stop"' 2   # ctrl c
if [[ $# -ne 1 ]]; then
    echo "Usage ./test.sh <10m>"
    exit 0
fi
START_TIME=$(date +"%c")
./x_start.sh
sleep $1
./x_stop.sh
END_TIME=$(date +"%c")
echo "##squid running duration"
echo "from $START_TIME"
echo "to   $END_TIME"
