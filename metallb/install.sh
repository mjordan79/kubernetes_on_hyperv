#!/bin/bash
helm repo add metallb https://metallb.github.io/metallb
kubectl create namespace metallb-system
helm install metallb metallb/metallb -f values.yaml -n metallb-system

