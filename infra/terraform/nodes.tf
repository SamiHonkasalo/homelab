resource "proxmox_vm_qemu" "k8s_node" {
  for_each    = var.nodes
  name        = each.value.name
  target_node = var.proxmox_target_node
  clone       = var.proxmox_template_name
  vmid        = each.value.vmid
  qemu_os     = "l26"
  scsihw      = "virtio-scsi-single"

  agent      = 1
  full_clone = true
  vga {
    memory = 0
    type   = "serial0"
  }

  onboot = true
  boot   = "order=ide2;scsi0;net0;ide0"

  cores  = 2
  memory = 4096

  cicustom  = var.proxmox_cloud_init_path
  ipconfig0 = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = each.value.macaddr
    firewall = true
  }

  disk {
    size    = "32G"
    storage = "local-lvm"
    type    = "scsi"
    ssd     = 1
    discard = "on"
  }
}
