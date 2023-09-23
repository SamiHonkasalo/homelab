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
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

# 06 Enable br_netfilter
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
modprobe br_netfilter

# 07 Install Kubernetes
# Download the Google Cloud public signing key:
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | gpg --yes --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
# Add the Kubernetes apt repository:
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

export KUBERNETES_VERSION=1.28.2
apt update
apt install -y \
   kubeadm=$KUBERNETES_VERSION-00 \
   kubectl=$KUBERNETES_VERSION-00 \
   kubelet=$KUBERNETES_VERSION-00

# 08 Enable and start kubelet service
systemctl daemon-reload
systemctl start kubelet
systemctl enable kubelet.service

# 09 reboot
reboot


