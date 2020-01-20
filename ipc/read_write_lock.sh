#!/bin/bash
# write lock sample
# This is a use case of flock
# Only one process can read or write this file
# Until the command finishes, the /tmp will be released
flock -x /tmp bash -c "sleep 10; echo ee > file" &

# When the /tmp is released, this command can get lock, and this command can execute
flock -x /tmp cat file
