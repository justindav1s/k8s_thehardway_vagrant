#!/bin/bash

ssh root@192.168.20.10 "wget -q https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/linux/amd64/kubectl"

ssh root@192.168.20.10 "cp kubectl /usr/local/bin/"
ssh root@192.168.20.10 "chmod +x /usr/local/bin/kubectl"

scp ../certs_config/ca.pem root@192.168.20.10:~/
scp ../certs_config/admin.pem root@192.168.20.10:~/
scp ../certs_config/admin-key.pem root@192.168.20.10:~/
scp ../certs_config/admin.pem root@192.168.20.10:~/


ssh root@192.168.20.10 "cat > ~/kubectl_init.sh <<EOF
kubectl config set-cluster kubernetes-the-hard-way \
--certificate-authority=ca.pem \
--embed-certs=true \
--server=https://192.168.20.10:6443


kubectl config set-credentials admin \
--client-certificate=admin.pem \
--client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
--cluster=kubernetes-the-hard-way \
--user=admin

kubectl config use-context kubernetes-the-hard-way   

kubectl get componentstatuses

kubectl get nodes
EOF"

ssh root@192.168.20.10 "chmod +x ~/kubectl_init.sh"
ssh root@192.168.20.10 "~/kubectl_init.sh"

ssh root@192.168.20.10 "firewall-cmd --zone=public --permanent --add-port=8443/tcp"
ssh root@192.168.20.10 "systemctl restart firewalld"

cat > dashboardd.sh <<EOF
#!/bin/bash

echo CONNECTING to : \
    \$(kubectl get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \\
    forwarding to 0.0.0.0:8443

kubectl port-forward  \\
     \$(kubectl get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \\
     --address 0.0.0.0 8443:8443 \\
     -n kubernetes-dashboard

EOF

scp dashboardd.sh root@192.168.20.10:/usr/local/bin/

ssh root@192.168.20.10 "chmod +x /usr/local/bin/dashboardd.sh"

cat > dashboardd.service <<EOF
[Unit]
Description=Kubernetes Dashboard port-forwarder
Documentation=https://github.com/justindav1s/k8s_thehardway_vagrant

[Service]
ExecStart=/bin/bash -c /usr/local/bin/dashboardd.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

scp dashboardd.service root@192.168.20.10:/etc/systemd/system/dashboardd.service

ssh root@192.168.20.10 "systemctl daemon-reload"
ssh root@192.168.20.10 "systemctl enable dashboardd"
ssh root@192.168.20.10 "systemctl start dashboardd"