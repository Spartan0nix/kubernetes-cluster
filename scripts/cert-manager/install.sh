# Install cert-manager to manage certificate using the CA
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.yaml

# Create a secret to store the CA information
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ca-key-pair
  namespace: cert-manager
data:
  tls.crt: $(kubectl get secrets ca-key-pair -n kube-system -o jsonpath="{.data.tls\.crt}")
  tls.key: $(kubectl get secrets ca-key-pair -n kube-system -o jsonpath="{.data.tls\.key}")
EOF

# Wait for pod to boot up before using cert-manager custom resources
sudo /bin/bash /vagrant/scripts/utils/wait_for_pod.sh "cert-manager"

# Create a ClusterIssuer to sign certificate with the CA informations
cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ca-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: ca-key-pair
EOF