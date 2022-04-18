Vagrant.configure("2") do |config|
  $hosts_config = <<-SCRIPT
    echo "192.168.80.10 master-node" >> /etc/hosts
    echo "192.168.80.11 worker-node-1" >> /etc/hosts
    echo "192.168.80.20 nfs-server" >> /etc/hosts
  SCRIPT

  config.vm.provision "shell", inline:  $hosts_config

  config.vm.define "nfs-server" do |nfs|
    nfs.vm.box = "debian/buster64"
    nfs.vm.hostname = "nfs-server"
    nfs.vm.network "private_network", ip: "192.168.80.20", name: "VirtualBox Host-Only Ethernet Adapter #3"
    nfs.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end
    nfs.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    nfs.vm.provision "shell", path: "scripts/nfs.sh"
  end

  config.vm.define "master-node" do |master|
    master.vm.box = "debian/buster64"
    master.vm.hostname = "master-node"
    master.vm.network "private_network", ip: "192.168.80.10", name: "VirtualBox Host-Only Ethernet Adapter #3"
    master.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    master.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    master.vm.provision "shell", path: "scripts/cluster/common.sh"
    master.vm.provision "shell", path: "scripts/cluster/ca-cert.sh"
    master.vm.provision "shell", path: "scripts/cluster/master.sh"
  end

  config.vm.define "worker-node-1" do |node|
    node.vm.box = "debian/buster64"
    node.vm.hostname = "worker-node-1"
    node.vm.network "private_network", ip: "192.168.80.11", name: "VirtualBox Host-Only Ethernet Adapter #3"
    node.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end
    node.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    node.vm.provision "shell", path: "scripts/cluster/common.sh"
    node.vm.provision "shell", path: "scripts/cluster/node.sh"
    node.vm.provision "shell", path: "scripts/cert-manager/install.sh"
    # Install extended components
    node.vm.provision "shell", path: "scripts/metrics-server/install.sh"
    node.vm.provision "shell", path: "scripts/ingress/install.sh"
    # node.vm.provision "shell", path: "app/zabbix/server/install.sh", args: "--install"
    # node.vm.provision "shell", path: "app/zabbix/agent/install.sh", args: "--install"
    node.vm.provision "shell", path: "app/prometheus/install.sh", args: "--install"
  end
end
