#!/bin/sh

echo "Deleting containers"
docker rm -f $(docker ps -qa)

echo "Deleting volumes"
docker volume prune

echo "Deleting networks"
docker network prune

cleanupdirs="/opt/rancher /var/lib/etcd /etc/kubernetes /etc/cni /opt/cni /var/lib/cni /var/run/calico /opt/rke"

for dir in $cleanupdirs; do
  echo "Removing $dir"
  rm -rf $dir
done

