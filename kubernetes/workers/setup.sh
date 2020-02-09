#!/bin/bash

POD_CIDR="10.10.10.0/23"

for INTERNAL_IP in 192.168.20.21 192.168.20.22 192.168.20.23; do

echo Linking resolv.conf
ssh root@${INTERNAL_IP} "mkdir -p /run/systemd/resolve/
ln -s /etc/resolv.conf /run/systemd/resolve/resolv.conf
ls -ltr /run/systemd/resolve/"

echo Swiching Off Swap.
ssh root@${INTERNAL_IP} "swapoff -a
  cat /etc/fstab | sed '/ swap / s/^\(.*\)$/#\1/g' > /etc/fstab.bak
  mv -f /etc/fstab.bak /etc/fstab
  cat /etc/fstab"

ssh root@${INTERNAL_IP} "systemctl disable firewalld"
ssh root@${INTERNAL_IP} "systemctl stop firewalld"

done

i=0

for INTERNAL_IP in 192.168.20.21 192.168.20.22 192.168.20.23; do

POD_CIDR="192.168.30.0/24"
//POD_CIDR="10.244.0.0/16"

cat > ${INTERNAL_IP}.10-bridge.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF
scp ${INTERNAL_IP}.10-bridge.conf root@${INTERNAL_IP}:/etc/cni/net.d/10-bridge.conf

cat > ${INTERNAL_IP}.99-loopback.conf <<EOF
{
    "cniVersion": "0.3.1",
    "name": "lo",
    "type": "loopback"
}
EOF
scp ${INTERNAL_IP}.99-loopback.conf root@${INTERNAL_IP}:/etc/cni/net.d/99-loopback.conf

ssh root@${INTERNAL_IP} "mkdir -p /etc/containerd/"

ssh root@${INTERNAL_IP} "cat << EOF | sudo tee /etc/containerd/config.toml
[plugins]
  [plugins.cri.containerd]
    snapshotter = \"overlayfs\"
    [plugins.cri.containerd.default_runtime]
      runtime_type = \"io.containerd.runtime.v1.linux\"
      runtime_engine = \"/usr/local/bin/runc\"
      runtime_root = \"\"
EOF"


ssh root@${INTERNAL_IP} "cat <<EOF | sudo tee /etc/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF"

ssh root@${INTERNAL_IP} "cp worker${i}-key.pem worker${i}.pem /var/lib/kubelet/"
ssh root@${INTERNAL_IP} "cp worker${i}.kubeconfig /var/lib/kubelet/kubeconfig"
ssh root@${INTERNAL_IP} "cp ca.pem /var/lib/kubernetes/"

ssh root@${INTERNAL_IP} "cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: \"/var/lib/kubernetes/ca.pem\"
authorization:
  mode: Webhook
clusterDomain: \"cluster.local\"
clusterDNS:
  - \"10.32.0.10\"
podCIDR: \"${POD_CIDR}\"
resolvConf: \"/etc/resolv.conf\"
runtimeRequestTimeout: \"15m\"
tlsCertFile: \"/var/lib/kubelet/worker${i}.pem\"
tlsPrivateKeyFile: \"/var/lib/kubelet/worker${i}-key.pem\"
EOF"


cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

scp kubelet.service root@${INTERNAL_IP}:/etc/systemd/system/kubelet.service

ssh root@${INTERNAL_IP} "cp kube-proxy.kubeconfig /var/lib/kube-proxy/kubeconfig"

ssh root@${INTERNAL_IP} "cat <<EOF | sudo tee /var/lib/kube-proxy/kube-proxy-config.yaml
kind: KubeProxyConfiguration
apiVersion: kubeproxy.config.k8s.io/v1alpha1
clientConnection:
  kubeconfig: \"/var/lib/kube-proxy/kubeconfig\"
mode: \"iptables\"
clusterCIDR: \"192.168.128.0/21\"
EOF"


cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/var/lib/kube-proxy/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

scp kube-proxy.service root@${INTERNAL_IP}:/etc/systemd/system/kube-proxy.service

ssh root@${INTERNAL_IP} "systemctl daemon-reload"
ssh root@${INTERNAL_IP} "systemctl enable containerd kubelet kube-proxy"
ssh root@${INTERNAL_IP} "systemctl restart containerd kubelet kube-proxy"

i=$((i+1))

done

rm -rf *.service *.conf