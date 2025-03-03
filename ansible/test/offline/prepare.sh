#!/bin/sh
for host in 10.240.0.80 10.240.0.81; do
    echo "Remove ssh key of $host from known_hosts"
    ssh-keygen -R $host

    echo "Remove default route on $host"
    ssh -i ~/.vagrant.d/insecure_private_key vagrant@$host sudo ip route delete default
done
