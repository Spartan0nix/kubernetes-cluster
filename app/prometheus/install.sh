#!/bin/bash

case $1 in
    --install)
    # Add the prometheus helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update

    # Install the prometheus stack
    helm install prometheus prometheus-community/kube-prometheus-stack

    # Wait for prometheus pod to boot up
    /bin/bash /vagrant/scripts/utils/wait_for_pod.sh "default"

    # Deploy on ingress rule to expose Grafana outside of the cluster
    /usr/bin/kubectl apply -f /vagrant/app/prometheus/ingress.yaml
    ;;

    --uninstall)
    # Remove prometheus ingress
    /usr/bin/kubectl delete -f /vagrant/app/prometheus/ingress.yaml
    # Uninstall prometheus helm chart
    helm uninstall prometheus
    # Remove prometheus repo
    helm repo remove prometheus-community
    ;;

    *)
    echo "When using the installer script for prometheus, use one of the following arguments : --install OR --uninstall."
esac