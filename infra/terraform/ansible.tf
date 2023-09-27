resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tftpl", {
    control_planes = proxmox_vm_qemu.k8s_control_plane
    nodes          = proxmox_vm_qemu.k8s_node
  })
  filename = "${path.module}/../ansible/inventory"
}


resource "ansible_playbook" "common_control_planes" {
  for_each  = var.control_planes
  name      = each.value.name
  playbook  = "${path.module}/../ansible/playbooks/common"
  verbosity = 6
}

resource "ansible_playbook" "common_nodes" {
  for_each  = var.nodes
  name      = each.value.name
  playbook  = "${path.module}/../ansible/playbooks/common"
  verbosity = 6
}
