Vagrant.configure("2") do |config|

    # TODO - Try to refactor with a loop for each number of VM in the deployment
    config.vm.provision "shell", inline:  <<-SCRIPT
    # Add an entry for each node in the cluster
    if [ -z "$(cat /etc/hosts | grep '192.168.80.10 cluster-endpoint')" ];then echo "192.168.80.10 cluster-endpoint" >> /etc/hosts; fi
    if [ -z "$(cat /etc/hosts | grep '192.168.80.11 control-node-1')" ];then echo "192.168.80.11 control-node-1" >> /etc/hosts; fi
    if [ -z "$(cat /etc/hosts | grep '192.168.80.12 control-node-2')" ];then echo "192.168.80.12 control-node-2" >> /etc/hosts; fi
    if [ -z "$(cat /etc/hosts | grep '192.168.80.13 control-node-3')" ];then echo "192.168.80.13 control-node-3" >> /etc/hosts; fi
    # if [ -z "$(cat /etc/hosts | grep '192.168.80.20 worker-1')" ];then echo "192.168.80.20 worker-1" >> /etc/hosts; fi
    # if [ -z "$(cat /etc/hosts | grep '192.168.80.30 nfs-server')" ];then echo "192.168.80.30 nfs-server" >> /etc/hosts; fi
    SCRIPT

    # config.vm.define "nfs-server" do |nfs|
    #   nfs.vm.box = "debian/bullseye64"
    #   nfs.vm.hostname = "nfs-server"
    #   nfs.vm.network "private_network", ip: "192.168.80.30"
    #   nfs.vm.provider "virtualbox" do |vb|
    #     vb.memory = 1024
    #     vb.cpus = 1
    #   end
    #   nfs.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    #   nfs.vm.provision "ansible_local" do |ansible|
    #     ansible.playbook = "ansible/main.yml"
    #     ansible.tags = "nfs"
    #   end
    # end

    config.vm.define "control-plane-haproxy" do |haproxy|
      haproxy.vm.box = "debian/bullseye64"
      haproxy.vm.hostname = "control-plane-haproxy"
      haproxy.vm.network "private_network", ip: "192.168.80.10"
      haproxy.vm.provider "virtualbox" do |vb|
        vb.memory = 512
        vb.cpus = 1
      end

      config.vm.provision "shell" do |shell|
        ssh_pub_key = File.readlines("#{ENV["WSL_HOME_DIR"]}\\.ssh\\id_ansible_kubernetes_cluster.pub").first.strip
        shell.inline = <<-SHELL
        echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
        SHELL
      end
    end

    config.vm.define "control-node-1" do |master|
      master.vm.box = "node-box"
      master.vm.hostname = "control-node-1"
      master.vm.network "private_network", ip: "192.168.80.11"
      master.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 2
      end
    end

    # TODO - Switch to a loop from 1 to x
    # config.vm.define "control-node-2" do |master|
    #   master.vm.box = "node-box"
    #   master.vm.hostname = "control-node-2"
    #   master.vm.network "private_network", ip: "192.168.80.12"
    #   master.vm.provider "virtualbox" do |vb|
    #     vb.memory = 2048
    #     vb.cpus = 2
    #   end
    # end

    # config.vm.define "control-node-3" do |master|
    #   master.vm.box = "node-box"
    #   master.vm.hostname = "control-node-3"
    #   master.vm.network "private_network", ip: "192.168.80.13"
    #   master.vm.provider "virtualbox" do |vb|
    #     vb.memory = 2048
    #     vb.cpus = 2
    #   end
    # end

    # config.vm.define "worker-1" do |worker|
    #   worker.vm.box = "node-box"
    #   worker.vm.hostname = "worker-1"
    #   worker.vm.network "private_network", ip: "192.168.80.20"
    #   worker.vm.provider "virtualbox" do |vb|
    #     vb.memory = 2048
    #     vb.cpus = 2
    #   end
    # end
 
end
