#!/bin/bash

# install.sh
# Run in all k8s nodes and the control plane


# 01 Wait for the cache lock to be free
# 02 install containerd and create the initial config
apt-get  -o DPkg::Lock::Timeout=300 install -y apt-transport-https ca-certificates curl
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
echo 1 > /proc/sys/net/ipv4/ip_forward

# 06 Network configuration
cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

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

# 08 Reload sysctl
sysctl --system


