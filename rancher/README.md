# Installing a Rancher Kubernetes cluster (RKE) and install Rancher into it.

## 1. Installing RKE and the Kubernetes cluster.
---------------------------------------------
Ensure you're on the config virtual machine. Make sure you can reach all the nodes you want for the local cluster (the master cluster)
through passwordless ssh. Download and install the rke binary, put it somewhere in the path. Also download and install Helm.

## 2. Edit the cluster.yml file with the IPs of your nodes and the roles.

    nodes:
      - address: 192.169.0.10
        user: root
        role: [controlplane, worker, etcd]
      - address: 192.169.0.15
        user: root
        role: [controlplane, worker, etcd]
      - address: 192.169.0.20
        user: root
        role: [controlplane, worker, etcd]
    services:
      etcd:
        snapshot: true
        creation: 6h
        retention: 24h

    # Required for external TLS termination with
    # ingress-nginx v0.22+
    ingress:
      provider: nginx
      options:
        use-forwarded-headers: "true"

## 3. Launch the RKE installation using the command:
   
    rke up --config cluster.yml

This will spin-up a Kubernetes cluster. Once it's ready, you will obtain the kube_config file. Put in $HOME/.kube/config
Now you can check the status of the local cluster launching the command:

    kubectl cluster-info

## 4. Installing Rancher 2.x on the Kubernetes local cluster.

> Install Rancher. If you want to use your own CA, set privateCA=true 

    kubectl create namespace cattle-system && \
	     helm repo add rancher-stable https://releases.rancher.com/server-charts/stable && \
	     helm install rancher rancher-stable/rancher \
  	      --namespace cattle-system \
  	      --set hostname=rancher.yourdomain.it \
  	      --set bootstrapPassword=admin \
  	      --set ingress.tls.source=secret \
  	      --set privateCA=true

> Set the tls-rancher-ingress secret with your certificates. These certs will be used in serving the Rancher UI through a web browser in https mode.

    kubectl -n cattle-system create secret tls tls-rancher-ingress \
	     --cert=certs/tls.crt \
	     --key=certs/tls.key

> If you chose to use your own CA, set it as well:

    kubectl -n cattle-system create secret generic tls-ca \
       --from-file=cacerts.pem=./certs/cacerts.pem

## 5. Updating certs.

> Updating the tls-rancher-ingress certificates:

    kubectl -n cattle-system create secret tls tls-rancher-ingress \
       --cert=certs/tls.crt \
       --key=certs/tls.key \
       --dry-run=client --save-config -o yaml | kubectl apply -f -

> Updating the CA certificate:

    kubectl -n cattle-system create secret generic tls-ca \
       --from-file=certs/cacerts.pem \
       --dry-run=client --save-config -o yaml | kubectl apply -f -

## 6. Cleanup
In case you have to start over for some reason, you can cleanup the environment using the following script:

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
