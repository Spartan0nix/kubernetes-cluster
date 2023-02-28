#!/bin/bash

# Retrieve pki certificates from the frist control node
ssh -i ~/.ssh/id_ansible_kubernetes_cluster vagrant@192.168.80.11 sudo cp -r /etc/kubernetes/pki /home/vagrant/
ssh -i ~/.ssh/id_ansible_kubernetes_cluster vagrant@192.168.80.11 sudo chown vagrant:vagrant -R /home/vagrant/pki
scp -i ~/.ssh/id_ansible_kubernetes_cluster -r vagrant@192.168.80.11:/home/vagrant/pki .
ssh -i ~/.ssh/id_ansible_kubernetes_cluster vagrant@192.168.80.11 rm -r /home/vagrant/pki

docker run -it --rm -v ./pki:/etc/kubernetes/pki bitnami/etcd:latest etcdctl \
    --cert=/etc/kubernetes/pki/etcd/peer.crt \
    --key=/etc/kubernetes/pki/etcd/peer.key \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --write-out=table \
    --endpoints=https://192.168.80.11:2379 \
    endpoint status