#!/bin/bash

# To display available Cgroups : sudo systemd-cgls
cat <<EOF > pod-config.json
{
    "metadata": {
        "name": "etcdctl-sandox",
        "namespace": "default",
        "attempt": 1,
        "uid": "hdishd83djaidwnduwk28bcsb"
    },
    "log_directory": "/tmp",
    "linux": {
        "cgroup_parent": "/kubepods.slice/kubepods-burstable.slice/kubepods-burstable-podhdishd83djaidwnduwk28bcsb.slice",
        "security_context": {
            "namespace_options": {
                "network": 2,
                "pid": 1
            }
        }
    }
}
EOF

cat <<EOF > container-config.json
{
  "metadata": {
      "name": "etcdctl"
  },
  "image":{
      "image": "bitnami/etcd:latest"
  },
  "command": [
      "etcdctl",
      "--cert=/etc/kubernetes/pki/etcd/peer.crt",
      "--key=/etc/kubernetes/pki/etcd/peer.key",
      "--cacert=/etc/kubernetes/pki/etcd/ca.crt",
      "--endpoints=https://192.168.80.11:2379",
      "endpoint",
      "health"
  ],
  "mounts": [
    {
        "container_path": "/etc/kubernetes/pki",
        "host_path": "/etc/kubernetes/pki",
        "readonly": true
    }
  ],
  "log_path":"etcdctl.0.log",
  "linux": {
    "security_context": {
        "namespace_options": {
            "network": 2,
            "pid": 1
        }
    }
  }
}
EOF

pod_id=$(sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock runp pod-config.json)

sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock run container-config.json pod-config.json
