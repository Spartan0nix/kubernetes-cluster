#!/bin/bash

case $1 in
  --install)
    echo "Installing zabbix server"
    /usr/bin/kubectl create namespace "zabbix-server"
    /usr/bin/kubectl apply -f /vagrant/app/zabbix/server/.
    /bin/bash /vagrant/scripts/utils/wait_for_pod.sh "zabbix-server"
    ;;

  --uninstall)
    echo "Uninstalling zabbix server"
    /usr/bin/kubectl delete -f /vagrant/app/zabbix/server/.
    /usr/bin/kubectl delete namespaces "zabbix-server"
    ;;

  *)
    echo "Zabbix server install script : use --install or --uninstall"
    ;;
esac
