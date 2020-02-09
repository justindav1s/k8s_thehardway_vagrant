#!/bin/bash

VM_IDS=$(VBoxManage list vms | awk '{print $2}' | sed 's/{//g' |  sed 's/}//g')

for VMID in $VM_IDS; do

    echo VM ID = ${VMID}
    VBoxManage snapshot ${VMID} list

done
