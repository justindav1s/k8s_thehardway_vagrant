#!/bin/bash

INTERNAL_IP=192.168.20.11

cat > rbac_cr.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat > rbac_crb.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF

scp rbac_cr.yaml root@${INTERNAL_IP}:~/
scp rbac_crb.yaml root@${INTERNAL_IP}:~/
ssh root@${INTERNAL_IP} "kubectl apply --kubeconfig admin.kubeconfig -f rbac_cr.yaml"
ssh root@${INTERNAL_IP} "kubectl apply --kubeconfig admin.kubeconfig -f rbac_crb.yaml"

rm -rf *.yaml