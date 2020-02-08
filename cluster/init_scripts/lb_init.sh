#!/bin/bash

# Install the required packages   
yum install haproxy dnsmasq -y

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

# Firewall Config
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --zone=public --permanent --add-port=6443/tcp
firewall-cmd --zone=public --permanent --add-service=dns

# dnsmasq config
cat > /etc/dnsmasq.d/kube <<EOF
no-dhcp-interface=eth0
bogus-priv
domain=lan
expand-hosts
local=/kube/
domain-needed
no-resolv
no-poll
server=8.8.8.8
server=8.8.4.4
EOF

cat > /etc/hosts <<EOF

192.168.20.10   lb nfs
192.168.20.11   controller0 etcd0
192.168.20.12   controller1 etcd1
192.168.20.13   controller2 etcd2
192.168.20.21   worker0
192.168.20.22   worker1
192.168.20.23   worker2
EOF

systemctl enable dnsmasq
systemctl start dnsmasq
systemctl status dnsmasq

# config so that dnsmasq on 192.168.20.10 will be used
nmcli con mod 'System eth0' ipv4.dns 192.168.20.10
nmcli con mod 'System eth0' ipv4.ignore-auto-dns yes
nmcli con down 'System eth0' && nmcli con up 'System eth0'

echo DONE. Rebooting

reboot