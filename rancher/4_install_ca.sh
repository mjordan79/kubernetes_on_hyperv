#!/bin/bash
kubectl -n cattle-system create secret generic tls-ca \
  --from-file=cacerts.pem=./certs/cacerts.pem

