#!/bin/bash

for INTERNAL_IP in 192.168.20.21 192.168.20.22 192.168.20.23; do

echo "IP = ${INTERNAL_IP}"

    for service in containerd kubelet kube-proxy; do
        echo $service : $(ssh -q root@${INTERNAL_IP} "systemctl status $service | grep Active")
    done

done


for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

echo "IP = ${INTERNAL_IP}"

ssh -q root@${INTERNAL_IP} "kubectl get nodes --kubeconfig admin.kubeconfig"

echo -e "\n\n"

done  