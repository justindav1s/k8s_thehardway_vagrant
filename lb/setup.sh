#!/bin/bash

IP=192.168.20.10

ssh root@${IP} "mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy_cfg.original"
scp haproxy.cfg root@${IP}:/etc/haproxy

ssh root@${IP} "sed 's/enforcing/permissive/' </etc/selinux/config >/etc/selinux/config.new"
ssh root@${IP} "cp /etc/selinux/config.new /etc/selinux/config"
ssh root@${IP} "rm -rf /etc/selinux/config.new"
ssh root@${IP} "systemctl daemon-reload"
ssh root@${IP} "systemctl enable haproxy"

#ssh root@${IP} "systemctl start haproxy"

ssh root@${IP} "reboot"