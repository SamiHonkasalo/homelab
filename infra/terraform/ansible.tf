resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tftpl", {
    control_planes = proxmox_vm_qemu.k8s_control_plane
    nodes          = proxmox_vm_qemu.k8s_node
  })
  filename = "${path.module}/../ansible/inventory"
}
