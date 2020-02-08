#!/bin/bash

# SSH config
mkdir ~/.ssh
cd ~/.ssh

cp ~vagrant/.ssh/id_rsa .
cp ~vagrant/.ssh/id_rsa.pub .
cp ~vagrant/.ssh/authorized_keys .

cat <<EOF > ~/.ssh/config
Host 192.168.20.*
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

chmod 600 id_rsa
chmod 600 authorized_keys
chmod 600 ~/.ssh/config

cd ~

yum -y install socat conntrack ipset container-selinux

wget -q https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.15.0/crictl-v1.15.0-linux-amd64.tar.gz
wget -q https://github.com/opencontainers/runc/releases/download/v1.0.0-rc8/runc.amd64
wget -q https://github.com/containernetworking/plugins/releases/download/v0.8.2/cni-plugins-linux-amd64-v0.8.2.tgz
wget -q https://github.com/containerd/containerd/releases/download/v1.2.9/containerd-1.2.9.linux-amd64.tar.gz
wget -q https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl
wget -q https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-proxy
wget -q https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubelet

mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

mkdir containerd
tar -xvf crictl-v1.15.0-linux-amd64.tar.gz
tar -xvf containerd-1.2.9.linux-amd64.tar.gz -C containerd
tar -xvf cni-plugins-linux-amd64-v0.8.2.tgz -C /opt/cni/bin/
mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
mv containerd/bin/* /bin/

rm -rf cni-plugins-linux-amd64-v0.8.2.tgz containerd* crictl-v1.15.0-linux-amd64.tar.gz

firewall-cmd --zone=public --permanent --add-port=6443/tcp
firewall-cmd --zone=public --permanent --add-port=10250/tcp

nmcli con mod 'System eth0' ipv4.dns 192.168.20.10
nmcli con mod 'System eth0' ipv4.ignore-auto-dns yes
nmcli con down 'System eth0' && nmcli con up 'System eth0'

echo DONE. Rebooting.

reboot