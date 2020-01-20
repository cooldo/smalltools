#!/bin/bash
# This script echo a string to "fifo" without reentrant
# If other process go into this script, it will wait for 0.1 seconds for the release of the lock.
# If timeout, it will return and don't write to "fifo"
exec 9>/tmp/file2.lock

# if is it locked, exit, else write to fifo
if ! flock -w 0.1 9;then
    echo "busyXXXX"
    exit 0
fi

echo -e "0\n1\n2\n3\n4\n5\n6\n7\n8\n9" > fifo
