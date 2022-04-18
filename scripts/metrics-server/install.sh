#!/bin/bash

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

/bin/bash /vagrant/scripts/utils/wait_for_pod.sh kube-system
