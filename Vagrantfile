# -*- mode: ruby -*-
# vi: set ft=ruby :

# Add the public key generate with 'make genkey' to the vm authorized key
def configureSSHKey(config)

  config.vm.provision "shell" do |shell|
    ssh_pub_key = File.readlines("#{ENV["WSL_HOME_DIR"]}\\.ssh\\id_ansible_kubernetes_cluster.pub").first.strip
    shell.inline = <<-SHELL
    echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
    SHELL
  end
  
end

Vagrant.configure("2") do |config|
  #-----------------------------------
  # Configurable variables
  #-----------------------------------
  controlNode = 1
  workerNode = 1
  #-----------------------------------

  # Disable default Vagrant mount 
  config.vm.synced_folder ".", "/vagrant", disabled: true
  # Dynamically update the /etc/hosts configuration for each node
  config.vm.provision "shell", path: "scripts/vagrant/configureHosts.sh", args: [controlNode, workerNode]
    
  # ---------------------------------
  # NFS Server (Storage)
  # ---------------------------------
  # config.vm.define "nfs-server" do |nfs|
  #   nfs.vm.box = "debian/bullseye64"
  #   nfs.vm.hostname = "nfs-server"
  #   nfs.vm.network "private_network", ip: "192.168.80.30"
  #   nfs.vm.provider "virtualbox" do |vb|
  #     vb.memory = 512
  #     vb.cpus = 1
  #   end
    
  #   configureSSHKey(nfs)
  # end

  # ---------------------------------
  # Load balancer (High availability)
  # ---------------------------------
  # config.vm.define "control-plane-haproxy" do |haproxy|
  #   haproxy.vm.box = "debian/bullseye64"
  #   haproxy.vm.hostname = "control-plane-haproxy"
  #   haproxy.vm.network "private_network", ip: "192.168.80.10"
  #   haproxy.vm.provider "virtualbox" do |vb|
  #     vb.memory = 512
  #     vb.cpus = 1
  #   end

  #   configureSSHKey(haproxy)
  # end

  # ---------------------------------
  # Control nodes (Kubernetes)
  # ---------------------------------
  (1..controlNode).each do |i|
    config.vm.define "control-node-#{i}" do |node|
      node.vm.box = "node-box"
      node.vm.hostname = "control-node-#{i}"
      node.vm.network "private_network", ip: "192.168.80.1#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
    end
  end

  # ---------------------------------
  # Worker nodes (Kubernetes)
  # ---------------------------------
  (1..workerNode).each do |i|
    config.vm.define "worker-node-#{i}" do |node|
      node.vm.box = "node-box"
      node.vm.hostname = "worker-node-#{i}"
      node.vm.network "private_network", ip: "192.168.80.2#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
    end
  end
 
end
