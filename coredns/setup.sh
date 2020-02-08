#!/bin/bash


kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

for i in {1..6}; do 
    kubectl get pods -l k8s-app=kube-dns -n kube-system
    sleep 5
done

kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600

sleep 10

kubectl get pods -l run=busybox
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes