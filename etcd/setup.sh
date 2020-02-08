#!/bin/bash

i=0
for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

cat > ${INTERNAL_IP}.etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name controller-${i} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller-0=https://192.168.20.11:2380,controller-1=https://192.168.20.12:2380,controller-2=https://192.168.20.13:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

scp ${INTERNAL_IP}.etcd.service root@${INTERNAL_IP}:/etc/systemd/system/etcd.service

ssh root@${INTERNAL_IP} "cat /etc/systemd/system/etcd.service"

ssh root@${INTERNAL_IP} "ls -ltr  /etc/etcd/kubernetes.pem"
ssh root@${INTERNAL_IP} "systemctl daemon-reload"
ssh root@${INTERNAL_IP} "systemctl enable etcd"
ssh root@${INTERNAL_IP} "systemctl start etcd"

i=$((i+1))

done 

rm -rf *.service