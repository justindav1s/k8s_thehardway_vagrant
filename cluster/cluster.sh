#!/bin/bash
set -x
SERVERS="lb controller0 controller1 controller2 worker0 worker1 worker2"
ACTION=$@

for SERVER in $SERVERS; do

    echo $ACTION : $SERVER
    rm -rf logs/$SERVER.out
    nohup vagrant $ACTION $SERVER > logs/$SERVER.out & 
    sleep 10

done
