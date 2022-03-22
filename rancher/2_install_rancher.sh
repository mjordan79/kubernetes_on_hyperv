#!/bin/bash
kubectl create namespace cattle-system && \
	helm repo add rancher-stable https://releases.rancher.com/server-charts/stable && \
	helm install rancher rancher-stable/rancher \
  	--namespace cattle-system \
  	--set hostname=host.domain.it \
  	--set bootstrapPassword=admin \
  	--set ingress.tls.source=secret \
  	--set privateCA=true

