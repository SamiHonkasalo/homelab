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

    # 03 install calico
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
    sleep 10 # wait for pods
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
    # Set the correct ip pool, has to be the same as the one given to kubeadm init
    sed -i 's/cidr:.*/cidr: 10.244.0.0\/16/' custom-resources.yaml
    kubectl create -f custom-resources.yaml
    sleep 60 # more waiting
else
    echo "kubeadm init failed. Is initialization already done?"
fi

exit 0


