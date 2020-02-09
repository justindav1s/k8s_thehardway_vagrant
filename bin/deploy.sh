#!/bin/bash

PROJ_HOME=$(pwd)/..

cd ${PROJ_HOME}/certs_config
./gen_certs.sh

# Setup ectd
cd ${PROJ_HOME}/etcd
./setup.sh
sleep 10
./status.sh

# Setup Kubernetes master/controllers
cd ${PROJ_HOME}/kubernetes/controllers
./setup.sh
./rbac.sh
sleep 10
./status.sh
# sleep 10
# ./status.sh

# Setup haproxy loadbalancer
cd ${PROJ_HOME}/lb
./setup.sh
sleep 10
./status.sh
# sleep 10
# ./status.sh

# Setup Kubernetes workers
cd ${PROJ_HOME}/kubernetes/workers
./setup.sh
sleep 10
./status.sh
# sleep 10
# ./status.sh

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/certs_config
./kubectl_setup.sh
sleep 10

#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/251ecdb3d3d5d34794ed174048f36ab10c287bcd/Documentation/kube-flannel.yml
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/d893bcbfe6b04791054aea6c7569dea4080cc289/Documentation/kube-flannel.yml
cd ${PROJ_HOME}/network
kubectl apply -f kube-flannel-legacy.yml
sleep 10
kubectl get pods --all-namespaces
sleep 10
kubectl get pods --all-namespaces
sleep 10
kubectl get pods --all-namespaces

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/coredns
./setup.sh

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/dashboard
./setup.sh