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

firewall-cmd --zone=public --list-ports
firewall-cmd --zone=public --permanent --add-port=6443/tcp
firewall-cmd --zone=public --permanent --add-port=2379/tcp
firewall-cmd --zone=public --permanent --add-port=2380/tcp
firewall-cmd --zone=public --permanent --add-port=22/tcp
firewall-cmd --zone=public --list-ports

wget -q "https://github.com/etcd-io/etcd/releases/download/v3.4.0/etcd-v3.4.0-linux-amd64.tar.gz"

tar -xf etcd-v3.4.0-linux-amd64.tar.gz 2>/dev/null
mv etcd-v3.4.0-linux-amd64/etcd* /usr/local/bin/
rm -rf etcd-v3.4.0-linux-amd64*

wget -q "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-apiserver"
wget -q "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-controller-manager"
wget -q "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kube-scheduler"
wget -q "https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"

chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

yum install nginx -y

sed 's/enforcing/permissive/' </etc/selinux/config >/etc/selinux/config.new
cp /etc/selinux/config.new /etc/selinux/config
rm -rf /etc/selinux/config.new

nmcli con mod 'System eth0' ipv4.dns 192.168.20.10
nmcli con mod 'System eth0' ipv4.ignore-auto-dns yes
nmcli con down 'System eth0' && nmcli con up 'System eth0'

echo DONE. Rebooting.

reboot