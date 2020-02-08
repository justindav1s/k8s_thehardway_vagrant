#!/bin/bash

ssh -q root@192.168.20.10 "curl -s --cacert ca.pem https://192.168.20.10:6443/version"
