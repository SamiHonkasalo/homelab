#!/bin/bash

SRC_IMG="https://cloud-images.ubuntu.com/minimal/releases/jammy/release-20220420/ubuntu-22.04-minimal-cloudimg-amd64.img"
IMG_NAME="ubuntu-2204.qcow2"
SRC_CLOUD_CONF="https://raw.githubusercontent.com/SamiHonkasalo/homelab/main/proxmox/cloud-init.yml"
CLOUD_CONF_NAME="cloud-init.yml"

TEMPLATE_NAME="ubuntu-2204-cloud"
VMID="9001"
MEM="2048"
DISK_SIZE="32G"
DISK_STOR="local-lvm"
NET_BRIDGE="vmbr0"

# Check if a VM with the same ID already exists
if qm status $VMID ; then
 echo "A vm with ID ${VMID} already exists, exiting"
 exit 1
fi

echo "A vm with Id ${VMID} does not exist, continuing"


# Create a directory for the cloud-init file and download it
echo "Creating a directory for cloud-init config file"
mkdir -p /var/lib/vz/cloud-init/
cd /var/lib/vz/cloud-init/
wget $SRC_CLOUD_CONF -O $CLOUD_CONF_NAME
echo "Downloaded ${CLOUD_CONF_NAME}"


# Install libguesetfs-tools to modify cloud image
apt update
apt install -y libguestfs-tools

# Download kvm image and rename
# Ubuntu img is actually qcow2 format and Proxmox doesn't like wrong extensions
wget $SRC_IMG -O $IMG_NAME 

# Ubuntu cloud img doesn't include qemu-guest-agent
virt-customize --install qemu-guest-agent -a $IMG_NAME

# Create cloud-init enabled Proxmox VM
qm create $VMID --name $TEMPLATE_NAME --memory $MEM --net0 virtio,bridge=$NET_BRIDGE
qm importdisk $VMID $IMG_NAME $DISK_STOR
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $DISK_STOR:vm-$VMID-disk-0,discard=on,ssd=1
qm set $VMID --ide2 $DISK_STOR:cloudinit
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --serial0 socket --vga serial0
qm set $VMID --ipconfig0 ip=dhcp
qm set $VMID --cicustom "user=local:cloud-init/${CLOUD_CONF_NAME}"
qm resize $VMID scsi0 $DISK_SIZE

# Convert to template
qm template $VMID

# Remove downloaded image
rm $IMG_NAME