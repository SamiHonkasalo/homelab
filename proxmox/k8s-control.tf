resource "proxmox_vm_qemu" "k8s_control" {
  name        = "k8s-controller"
  desc        = "Kubernetes control plane"
  target_node = "pve-1"
  clone       = "ubuntu-2204-template"
  vmid        = "1001"

  agent = 1

  cores  = 2
  memory = 4096

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = "a6:0f:d8:ea:26:71"
    firewall = true
  }
}
