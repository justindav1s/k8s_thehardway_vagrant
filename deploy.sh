#!/bin/bash

PROJ_HOME=$(pwd)

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
sleep 10
./status.sh

# Setup haproxy loadbalancer
cd ${PROJ_HOME}/lb
./setup.sh
sleep 10
./status.sh
sleep 10
./status.sh

# Setup Kubernetes workers
cd ${PROJ_HOME}/kubernetes/workers
./setup.sh
sleep 10
./status.sh
sleep 10
./status.sh

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/certs_config
./kubectl_setup.sh
sleep 10

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/coredns
./setup.sh

# Setup kubectl cli for remote use
cd ${PROJ_HOME}/dashboard
./setup.sh