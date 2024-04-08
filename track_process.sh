#!/bin/bash

# As long as process is running ... 
while ps -o pid= -p $1; do
    # ... track process
    ps -p $1 -o uid,pid,c,%cpu,%mem,start,time,vsz,rsz | sed 's/ \+/\;/g' | tail -n1 >> log.csv
    sleep 0.5
done
