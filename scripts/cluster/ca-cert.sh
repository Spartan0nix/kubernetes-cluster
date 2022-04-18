#!/bin/bash

MASTER_IP="192.168.80.10"
# MASTER_CLUSTER_IP="172.17.0.1"

# Generate ca key
openssl genrsa -out ca.key 2048

# Generate the CA certificate using the ca key
openssl req -x509 -new -nodes -key ca.key -subj "/CN=${MASTER_IP}" -days 10000 -out ca.crt
# openssl req -x509 -new -nodes -config /vagrant/scripts/cluster/cert.conf -key ca.key -days 10000 -out ca.crt

# Move the file
sudo mkdir -p /etc/kubernetes/pki
sudo mv -f ca.crt /etc/kubernetes/pki/
sudo mv -f ca.key /etc/kubernetes/pki/