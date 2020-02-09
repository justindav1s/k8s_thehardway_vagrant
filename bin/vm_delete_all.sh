#!/bin/bash

VM_IDS=$(VBoxManage list vms | awk '{print $2}' | sed 's/{//g' |  sed 's/}//g')


PROJ_HOME=$(pwd)/..

for VMID in $VM_IDS; do

    echo VM ID = ${VMID}
    VBoxManage controlvm ${VMID} poweroff
    VBoxManage unregistervm ${VMID} --delete
    sleep 5
done

rm -rf ${PROJ_HOME}/cluster/.vagrant

rm -rf ~VirtualBox\ VMs/lb
rm -rf ~/VirtualBox\ VMs/controller0
rm -rf ~/VirtualBox\ VMs/controller1
rm -rf ~/VirtualBox\ VMs/controller2
rm -rf ~/VirtualBox\ VMs/worker0
rm -rf ~/VirtualBox\ VMs/worker1
rm -rf ~/VirtualBox\ VMs/worker2
rm -rf ~/VirtualBox\ VMs/generic-centos7*

ls -ltr ~/VirtualBox\ VMs/