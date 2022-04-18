#!/bin/bash
echo "[master-script] : Started"

MASTER_IP="192.168.80.10"
NODENAME=$(hostname -s)
POD_CIDR="172.16.0.0/16"
SERVICE_CIDR="172.17.0.0/22"
KUBE_CONFIG="/vagrant/config/config"
JOIN_TOKEN_FILE="/vagrant/config/join.sh"

# Pulling required control images to set up the cluster
echo "[master-script] : Pulling required control images"
sudo kubeadm config images pull

# Bootstrap the Kubernetes control-plane node
echo "[master-script] : Boostraping the kubernetes controle-plane"
sudo kubeadm init --node-name $NODENAME \
    --ignore-preflight-errors="Swap" \
    --config /vagrant/scripts/cluster/kubeadm-config.yaml

# Allow root to use the control-plane
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save the kubeadmin command to join nodes to the cluster and the default .kube config
echo "[master-script] : Saving the kubeadmin command to join nodes to the cluster"
# Overwrite if necessary
sudo cp -f /etc/kubernetes/admin.conf $KUBE_CONFIG
kubeadm token create --print-join-command > $JOIN_TOKEN_FILE
sudo chmod +x $JOIN_TOKEN_FILE

# Install Calico 
echo "[master-script] : Installing calico"
# Prevent calico from using the wrong interface
IP_AUTODETECTION_METHOD=cidr=192.168.80.0/24
HOSTNAME=$(hostname -s)
sudo rm -rf /var/lib/cni && sudo rm -rf /etc/cni/net.d
sudo curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml

echo "[master-script] : Calico installed"

# Make kubectl run as a non-root user
sudo -i -u vagrant bash << EOF
mkdir -p /home/vagrant/.kube
sudo cp -f /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
EOF

# Wait for each kube-system pod to start
sudo /bin/bash /vagrant/scripts/utils/wait_for_pod.sh "kube-system"

# Approve $HOSTNAME csr
echo "[master-script] : Approving csr for $HOSTNAME"
sudo /bin/bash /vagrant/scripts/utils/approve_csr.sh $HOSTNAME

# Create a secret to store the CA information
echo "[master-script] : Storing CA certificate and key"
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ca-key-pair
  namespace: kube-system
data:
  tls.crt: $(sudo cat /etc/kubernetes/pki/ca.crt | base64 | tr -d '\n')
  tls.key: $(sudo cat /etc/kubernetes/pki/ca.key | base64 | tr -d '\n')
EOF

echo "[master-script] : Ended"