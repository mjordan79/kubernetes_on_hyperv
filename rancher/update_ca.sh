#!/bin/bash
kubectl -n cattle-system create secret generic tls-ca \
  --from-file=certs_new/converted/cacerts.pem \
  --dry-run=client --save-config -o yaml | kubectl apply -f -

