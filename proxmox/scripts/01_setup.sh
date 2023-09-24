#!/bin/bash

# 01_setup.sh
# Run in all k8s nodes and the control plane


# 01 install containerd and create the initial config
apt install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# 02 Disable swap
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 03 Enable bridging
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward

cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

modprobe overlay
modprobe br_netfilter

exit 0
# Reboot


