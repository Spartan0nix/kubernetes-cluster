#!/bin/bash

if [[ $# -lt 2 ]]
then
    echo "Missing required arguments:"
    echo "- Node name"
    echo "- Path to the kubeconfig file"
    exit 1
fi

NODE_NAME=$1
ARGS="--kubeconfig=$2"

echo "Scheduling node for removal"
kubectl cordon $NODE_NAME $ARGS

echo "Draining node"
kubectl drain --ignore-daemonsets --force $NODE_NAME $ARGS

echo "Removing node"
kubectl delete node $NODE_NAME $ARGS

echo "Displaying remaining nodes"
kubectl get nodes $ARGS

exit 0
