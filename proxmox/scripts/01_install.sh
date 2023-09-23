#!/bin/bash

# install.sh
# Run in all k8s nodes and the control plane

# 01 

# 02 install containerd and create the initial config
apt install -y apt-transport-https ca-certificates curl
apt install containerd -y
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# 03 Enable SystemdCGroup
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# 04 Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 05 Enable bridging
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1' /etc/sysctl.conf

# 06 Enable br_netfilter
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter

# 07 Install Kubernetes
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
apt install kubeadm kubectl kubelet
apt-mark hold kubelet kubeadm kubectl

# 08 Enable and start kubelet service
systemctl daemon-reload
systemctl start kubelet
systemctl enable kubelet.service

# 09 reboot
reboot


