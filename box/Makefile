SHELL = /bin/bash

# Utils
ping:
	ansible \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		-i ./ansible/inventory.yml \
		-m ping \
		nodebox

facts:
	ansible \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		-i ./ansible/inventory.yml \
		-m setup \
		nodebox

up:
	vagrant.exe up

run-playbook:
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.240"

	ansible-playbook \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		--inventory ./ansible/inventory.yml \
		./ansible/main.yml

package:
	box_version=$(shell date +%Y%m%d); vagrant.exe package --output "node-box-$$box_version" "node-box"

	vagrant.exe destroy

	box_version=$(shell date +%Y%m%d); vagrant.exe box add --name node-box "./node-box-$$box_version"

clean:
	box_version=$(shell date +%Y%m%d); rm "./node-box-$$box_version"
	rm -r ./.vagrant

lint:
	ansible-lint ansible/main.yml

# Build the base box for the cluster nodes
build-node-box: up run-playbook package clean
