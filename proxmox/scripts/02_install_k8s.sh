#!/bin/bash

# 02_install_k8s.sh
# Run in all k8s nodes and the control plane

# 01 Setup keyrings
apt install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt update

# 02 Install required k8s packages
export KUBERNETES_VERSION=1.28.2-1.1
apt install -y \
   kubeadm=$KUBERNETES_VERSION \
   kubectl=$KUBERNETES_VERSION \
   kubelet=$KUBERNETES_VERSION
apt-mark hold kubelet kubeadm kubectl

exit 0


