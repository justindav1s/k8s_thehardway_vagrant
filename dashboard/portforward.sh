#!/bin/bash

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

echo GOTO : http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ 

kubectl port-forward  \
     $(kubectl get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 127.0.0.1 8001:8443 \
     -n kubernetes-dashboard
    