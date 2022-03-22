#!/bin/bash
kubectl -n cattle-system create secret tls tls-rancher-ingress \
  --cert=certs_new/converted/tls.crt \
  --key=certs_new/converted/tls.key \
  --dry-run=client --save-config -o yaml | kubectl apply -f -

