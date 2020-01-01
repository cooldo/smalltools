#!/bin/bash
rm -rf client_read
i=0
while read -r line
do
    ((i++))
    echo $i
    echo $line >> client_read
done < <(tail -f fifo)
