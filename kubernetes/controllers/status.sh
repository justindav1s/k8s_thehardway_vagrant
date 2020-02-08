#!/bin/bash

for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

echo "IP = ${INTERNAL_IP}"

ssh -q root@${INTERNAL_IP} "kubectl get componentstatuses --kubeconfig admin.kubeconfig"

ssh -q root@${INTERNAL_IP} "curl -s -H \"Host: kubernetes.default.svc.cluster.local\" -i http://127.0.0.1/healthz"
echo -e "\n\n"

done  