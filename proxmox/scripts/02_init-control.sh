#!/bin/bash

# 01 init cluster
IP=ip a | grep eth0 | cut -d " " --fields=6 | sed '2q;d' | awk -F'/' '{print $1}'
HOSTNAME=hostname
kubeadm init --control-plane-endpoint=$IP --node-name $HOSTNAME --pod-network-cidr=10.244.0.0/16

# 02 copy kubeconfig
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 03 install flannel
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml