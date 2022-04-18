#!/bin/bash

# Download go
sudo wget https://go.dev/dl/go1.17.8.linux-amd64.tar.gz
# Remove old version if present
sudo rm -rf /usr/local/go

# Install go for root
sudo tar -C /usr/local -xzf go1.17.8.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
echo "PATH=$PATH:/usr/local/go/bin" >> /home/vagrant/.bashrc

# Remove the archive
sudo rm -f go1.17.8.linux-amd64.tar.gz