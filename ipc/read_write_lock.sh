#!/bin/bash
# flock example
cat << EOF
##################################################
use case 1, exlusive lock: one writer, one reader
##################################################
EOF
# Only one process can read or write this file
# process 1, write file
flock -x /tmp bash -c "echo process 1 write file;  echo ee > file; sleep 5; echo process 1 finish" &
sleep 2
# process 2, read file
flock -x /tmp bash -c "echo process 2 read file; cat file > /dev/null; sleep 5; echo process 2 finish" &

# process 3, read file
flock -x /tmp bash -c "echo process 3 read file; cat file > /dev/null ; sleep 5; echo process 3 finish"

sleep 5
cat << EOF
##################################################
use case 2, shared lock: one writer, multi readers
##################################################
EOF
# Only one process can write the file,multi-process can read this file
# process 1, write text.txt
flock -x text.txt bash -c "echo process 1 write file; echo aa >> text.txt ;sleep 5; echo process 1 finish" &
sleep 2
# process 2, read text.txt
flock -s text.txt bash -c "echo process 2 read file; cat text.txt >/dev/null;sleep 5; echo process 2 finish" &

# process 3, read text.txt, process 2 and process 3 can read text.txt at the same time after process 1 release the lock
flock -s text.txt bash -c "echo process 3 read file; cat text.txt >/dev/null ;sleep 5; echo process 3 finish"
