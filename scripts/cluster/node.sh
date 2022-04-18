#!/bin/bash
echo "[node-script] : Started"

echo "[node-script] : Adding node to the cluster"
sudo /bin/bash /vagrant/config/join.sh

echo "[node-script] : Creating root user config"
mkdir -p $HOME/.kube
sudo cp -i /vagrant/config/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Adding label to the newly added node
NODENAME=$(hostname -s)
kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker-new

# Wait for each node to start
/bin/bash /vagrant/scripts/utils/wait_for_node.sh

# Approve $NODENAME csr
echo "[master-script] : Approving csr for $NODENAME"
/bin/bash /vagrant/scripts/utils/approve_csr.sh $NODENAME

echo "[node-script] : Creating vagrant user config"
sudo -i -u vagrant bash << EOF
mkdir -p /home/vagrant/.kube
sudo cp -i /vagrant/config/config /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
EOF

echo "[node-script] : Ended"