SHELL = /bin/bash

genkey:
	ssh-keygen -t ed25519 -f ~/.ssh/id_ansible_kubernetes_cluster
	eval "$$(ssh-agent -s)"

reset-known-hosts:
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.10"
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.11"
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.21"
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.22"
	ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "192.168.80.31"

up:
	vagrant.exe up

destroy:
	vagrant.exe destroy

ssh-haproxy:
	ssh -i ~/.ssh/id_ansible_kubernetes_cluster vagrant@192.168.80.10

ping:
	ansible \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		--inventory ./cluster/ansible/inventory.yml \
		-m ping \
		control_plane

facts:
	ansible \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		--inventory ./cluster/ansible/inventory.yml \
		-m setup \
		control_plane

lint:
	ansible-lint ./cluster/ansible/main.yml

run-playbook:
	# Use 'make reset-known-hosts' in case of error
	
	ansible-playbook \
		--private-key ~/.ssh/id_ansible_kubernetes_cluster \
		--user vagrant \
		--inventory ./cluster/ansible/inventory.yml \
		./cluster/ansible/main.yml
