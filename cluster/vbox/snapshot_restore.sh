#!/bin/bash

SNAPSHOT_NAME=$1

VM_IDS=$(VBoxManage list vms | awk '{print $2}' | sed 's/{//g' |  sed 's/}//g')

for VMID in $VM_IDS; do

    echo VM ID = ${VMID}
    VBoxManage controlvm ${VMID} poweroff
    VBoxManage snapshot ${VMID} restore $SNAPSHOT_NAME
    VBoxManage startvm ${VMID} --type headless
    VBoxManage controlvm ${VMID} reset
done
