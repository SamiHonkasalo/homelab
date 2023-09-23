#!/bin/bash

# install.sh
# Run in all k8s nodes and the control plane

# 01 Sudo
sudo -i

# 02 install containerd and create the initial config
apt install -y apt-transport-https ca-certificates curl
sudo apt install containerd -y
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# 03 Enable SystemdCGroup
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# 04 Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 05 Enable bridging
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1' /etc/sysctl.conf

# 06 Enable br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter

# 07 Install Kubernetes
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sudo apt install kubeadm kubectl kubelet
sudo apt-mark hold kubelet kubeadm kubectl

# 08 Enable and start kubelet service
systemctl daemon-reload
systemctl start kubelet
systemctl enable kubelet.service

# 09 reboot
sudo reboot


