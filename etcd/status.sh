#!/bin/bash

for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

echo IP = ${INTERNAL_IP}


ssh -q root@${INTERNAL_IP} "ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem"

done  