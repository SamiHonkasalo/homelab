#!/bin/bash

# 03_init_control.sh
# Run only on the control plane

# 01 Setup variables
IP=$(ip a | grep eth0 | cut -d " " --fields=6 | sed '2q;d' | awk -F'/' '{print $1}')
HOSTNAME=$(hostname)
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
USER_ID=${SUDO_UID:-$(id -u)}
GROUP_ID=${SUDO_GID:-$(id -g)}

# 02 Initialize cluster
echo initializing control plane with IP ${IP} and hostname ${HOSTNAME}
if kubeadm init --control-plane-endpoint=$IP --node-name $HOSTNAME --pod-network-cidr=10.244.0.0/16 ; then
    # 02 copy kubeconfig
    echo creating directory $USER_HOME/.kube
    mkdir -p $USER_HOME/.kube
    cp -i /etc/kubernetes/admin.conf $USER_HOME/.kube/config
    chown ${USER_ID}:${GROUP_ID} $USER_HOME/.kube/config

    export KUBECONFIG=/etc/kubernetes/admin.conf

    # 03 install flannel
    kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
    sleep 60 # more waiting
else
    echo "kubeadm init failed. Is initialization already done?"
fi

exit 0


