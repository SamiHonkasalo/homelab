resource "proxmox_vm_qemu" "k8s_control" {
  name        = "k8s-controller"
  desc        = "Kubernetes control plane"
  target_node = "pve-1"
  clone       = "ubuntu-2204-cloud"
  vmid        = "1001"

  agent = 1

  onboot = true

  cores  = 2
  memory = 4096

  cicustom  = "user=local:snippets/cloud-init.yml"
  ipconfig0 = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = "a6:0f:d8:ea:26:71"
    firewall = true
  }
}
resource "proxmox_vm_qemu" "k8s_node_1" {
  name        = "k8s-node-1"
  desc        = "Kubernetes node 1"
  target_node = "pve-1"
  clone       = "ubuntu-2204-cloud"
  vmid        = "1002"

  agent = 1

  onboot = true

  cores  = 2
  memory = 4096

  cicustom  = "user=local:snippets/cloud-init.yml"
  ipconfig0 = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = "a6:0f:d8:ea:26:72"
    firewall = true
  }
}
