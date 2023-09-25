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

cat <<EOF > /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

exit 0
# Reboot


