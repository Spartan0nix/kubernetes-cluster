#!/bin/bash

if [[ $# -ne 2 ]]
then
    echo "Missing required arguments :"
    echo "[1] Number of control node"
    echo "[2] Number of worker node"

    exit 1
fi

controlNode=$1
workerNode=$2

echo "" >> /etc/hosts
echo "# Provide by vagrant shell provisionning at first boot" >> /etc/hosts
echo "192.168.80.10 cluster-endpoint" >> /etc/hosts
echo "192.168.80.30 nfs-server" >> /etc/hosts

for ((i = 1 ; i <= $controlNode ; i++))
do
  echo "192.168.80.1$i control-node-$i" >> /etc/hosts
done

for ((i = 1 ; i <= $workerNode ; i++))
do
  echo "192.168.80.2$i worker-node-$i" >> /etc/hosts
done

exit 0