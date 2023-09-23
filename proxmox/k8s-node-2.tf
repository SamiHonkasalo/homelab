resource "proxmox_vm_qemu" "k8s_node_2" {
  name        = "k8s-node-2"
  desc        = "Kubernetes node 2"
  target_node = "pve-1"
  clone       = "ubuntu-2204-cloud"
  vmid        = "1003"

  agent      = 1
  full_clone = true

  onboot = true

  cores  = 2
  memory = 4096

  cicustom  = "user=local:snippets/cloud-init.yml"
  ipconfig0 = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = "a6:0f:d8:ea:26:73"
    firewall = true
  }
}
