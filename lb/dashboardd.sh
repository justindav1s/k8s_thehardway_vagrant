#!/bin/bash

echo CONNECTING to :     $(kubectl get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
    forwarding to 0.0.0.0:8443

kubectl port-forward  \
     $(kubectl get pods -l k8s-app=kubernetes-dashboard -o jsonpath="{.items[0].metadata.name}" -n kubernetes-dashboard) \
     --address 0.0.0.0 8443:8443 \
     -n kubernetes-dashboard

