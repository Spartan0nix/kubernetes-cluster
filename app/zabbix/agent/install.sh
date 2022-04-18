#!/bin/bash

NAMESPACE="zabbix-monitoring"
GO_DIR="/usr/local/go"

if [ ! -d "$GO_DIR" ];then
    /bin/bash /vagrant/app/zabbix/api/install_go.sh
fi

case $1 in
    --install)
        echo "Installing zabbix agent"
        # Add chart repo
        helm repo add zabbix-chart-6.0 https://cdn.zabbix.com/zabbix/integrations/kubernetes-helm/6.0

        # Create zabbix namespace
        kubectl create namespace $NAMESPACE

        # Update config_file value
        helm show values zabbix-chart-6.0/zabbix-helm-chrt > $HOME/zabbix_values.yaml
        sed -i 's/value: "127.0.0.1"/value: "zabbix-server.default.svc.cluster.local"/g' $HOME/value.yaml
        sed -i 's/value: 0.0.0.0\/0/value: "zabbix-server.default.svc.cluster.local"/g' $HOME/value.yaml

        # Install chart
        helm install zabbix zabbix-chart-6.0/zabbix-helm-chrt --dependency-update -f $HOME/zabbix_values.yaml -n $NAMESPACE

        # Wait for pods to bootup
        /bin/bash /vagrant/scripts/utils/wait_for_pod.sh $NAMESPACE
        # Get credentials
        /bin/bash /vagrant/app/zabbix/agent/install.sh --add-hosts
        exit 0
        ;;
    --uninstall)
        echo "Uninstalling zabbix agent"
        # Uninstal chart
        helm delete zabbix -n zabbix-monitoring
        helm repo remove zabbix-chart-6.0
        kubectl delete namespace "zabbix-monitoring"
        exit 0
        ;;
    --add-hosts)
        echo "Adding zabbix agent host's to the zabbix server"
        namespace_status=$(kubectl get namespaces $NAMESPACE -o jsonpath="{.status.phase}" 2>/dev/null)
        if [ -z $namespace_status ];then
            echo "Namespace '$NAMESPACE' does not exist."
            exit 1
        fi
        
        KUBE_API_SERVER_ENDPOINT=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"kubernetes\")].cluster.server}")
        ZABBIX_SA_TOKEN=$(kubectl get secret zabbix-service-account -n $NAMESPACE -o jsonpath={.data.token} | base64 -d)
        ZABBIX_WEB_IP=$(kubectl get svc zabbix-web -o jsonpath="{.spec.clusterIP}")
        ZABBIX_WEB_PORT=$(kubectl get svc zabbix-web -o jsonpath="{.spec.ports[0].port}")

        /usr/local/go/bin/go run /vagrant/app/zabbix/api/add_hosts.go $KUBE_API_SERVER_ENDPOINT $ZABBIX_SA_TOKEN $ZABBIX_WEB_IP $ZABBIX_WEB_PORT
        ;;
esac

