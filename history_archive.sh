#!/bin/bash
# backup .bash_history to .bash_history_archive
umask 077
max_lines=10000

linecount=$(wc -l < ~/.bash_history)

if ((linecount > max_lines)); then
    prune_lines=$((linecount - max_lines))
    head -n "$prune_lines" ~/.bash_history >> ~/.bash_history.archive &&
    sed -e "1,${prune_lines}d"  ~/.bash_history > ~/".bash_history.tmp$$" &&
    mv ~/".bash_history.tmp$$" ~/.bash_history
fi
