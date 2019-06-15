#!/bin/bash
#
# This is a wrapper for scp
#

INPUT=$@
COUNT=$#
let INPUT_NUMBER=$COUNT-1
FROM=$(echo $INPUT |  tr -s ' ' | cut -d' ' -f -$INPUT_NUMBER)
TO=$(echo $INPUT | cut -d " " -f $COUNT)

SERVER_58="gaoqiang@109.105.115.58:/home/gaoqiang/share"
SERVER_63="gaoq@109.105.115.63:/home/ivi/gaoq/share"
VM="root@109.105.116.20:/media/sf_share/vbox"
LO1="root@109.105.121.36:/home/share/share"

case $TO in
    58) echo "cp to $SERVER_58"
        scp -P 22 $FROM $SERVER_58
        exit 0
        ;;
    63) echo "cp to $SERVER_63"
        scp -P 22 $FROM $SERVER_63
        exit 0
        ;;
    lo1) echo "cp to $LO1"
        scp -P 22 $FROM $LO1
        exit 0
        ;;
    vm) echo "cp to $VM"
        scp -P 6667 $FROM $VM
        exit 0
        ;;
    *) echo "cannot find target $TO"
        exit 1
        ;;
esac
