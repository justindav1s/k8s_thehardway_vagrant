#!/bin/bash


for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

    ssh root@${INTERNAL_IP} "mkdir -p /var/lib/kubernetes/"

    ssh root@${INTERNAL_IP} "mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem encryption-config.yaml /var/lib/kubernetes/"

    ssh root@${INTERNAL_IP} "mv kube-controller-manager.kubeconfig /var/lib/kubernetes/"

    ssh root@${INTERNAL_IP} "mv kube-scheduler.kubeconfig /var/lib/kubernetes/"

    ssh root@${INTERNAL_IP} "ls -ltr /var/lib/kubernetes/"
done


for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

cat > ${INTERNAL_IP}.kube-apiserver.service <<EOF
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${INTERNAL_IP} \\
  --allow-privileged=true \\
  --apiserver-count=3 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=https://192.168.20.11:2379,https://192.168.20.12:2379,https://192.168.20.13:2379 \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config=api/all \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
scp ${INTERNAL_IP}.kube-apiserver.service root@${INTERNAL_IP}:/etc/systemd/system/kube-apiserver.service
ssh root@${INTERNAL_IP} "cat /etc/systemd/system/kube-apiserver.service"


cat > ${INTERNAL_IP}.kube-controller-manager.service <<EOF
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --address=0.0.0.0 \\
  --cluster-cidr=192.168.128.0/21 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
scp ${INTERNAL_IP}.kube-controller-manager.service root@${INTERNAL_IP}:/etc/systemd/system/kube-controller-manager.service
ssh root@${INTERNAL_IP} "cat /etc/systemd/system/kube-controller-manager.service"


cat > kube-scheduler.yaml <<EOF
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF
ssh root@${INTERNAL_IP} "mkdir -p /etc/kubernetes/config/"
scp kube-scheduler.yaml root@${INTERNAL_IP}:/etc/kubernetes/config/kube-scheduler.yaml
ssh root@${INTERNAL_IP} "ls -ltr /etc/kubernetes/config/kube-scheduler.yaml"


cat > kube-scheduler.service <<EOF
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
scp kube-scheduler.service root@${INTERNAL_IP}:/etc/systemd/system/kube-scheduler.service
ssh root@${INTERNAL_IP} "ls -ltr /etc/systemd/system/kube-scheduler.service"

done

for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

  ssh root@${INTERNAL_IP} "systemctl daemon-reload"
  ssh root@${INTERNAL_IP} "systemctl enable kube-apiserver kube-controller-manager kube-scheduler"
  ssh root@${INTERNAL_IP} "systemctl start kube-apiserver kube-controller-manager kube-scheduler"

done


for INTERNAL_IP in 192.168.20.11 192.168.20.12 192.168.20.13; do

cat > kubernetes.conf <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF

    scp kubernetes.conf root@${INTERNAL_IP}:/etc/nginx/conf.d/kubernetes.conf

    ssh root@${INTERNAL_IP} "systemctl daemon-reload"
    ssh root@${INTERNAL_IP} "systemctl enable nginx"
    ssh root@${INTERNAL_IP} "systemctl start nginx"

done

rm -rf *.service kube* 