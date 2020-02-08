#!/bin/bash


kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml

for i in {1..5}; do 
    kubectl get pods -n kubernetes-dashboard
    sleep 7
done

kubectl apply -f admin_user.yaml

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
