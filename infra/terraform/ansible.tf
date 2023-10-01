resource "ansible_host" "control_planes" {
  for_each = proxmox_vm_qemu.k8s_control_plane
  name     = each.value.default_ipv4_address
  groups   = ["control_planes"]
  variables = {
    ansible_user                 = "saho"
    ansible_ssh_private_key_file = "~/.ssh/pve"
  }
}

resource "ansible_host" "nodes" {
  for_each = proxmox_vm_qemu.k8s_node
  name     = each.value.default_ipv4_address
  groups   = ["nodes"]
  variables = {
    ansible_user                 = "saho"
    ansible_ssh_private_key_file = "~/.ssh/pve"
  }
}


# resource "ansible_playbook" "control_planes_common" {
#   for_each   = ansible_host.control_planes
#   name       = each.value.name
#   groups     = each.value.groups
#   playbook   = "${path.module}/../ansible/playbooks/common.yaml"
#   replayable = true
#   extra_vars = {
#     ansible_host                 = each.value.name
#     ansible_groups               = join(",", each.value.groups)
#     ansible_user                 = "saho"
#     ansible_ssh_private_key_file = "~/.ssh/pve"
#   }
# }

# resource "ansible_playbook" "nodes_common" {
#   for_each   = ansible_host.nodes
#   name       = each.value.name
#   groups     = each.value.groups
#   playbook   = "${path.module}/../ansible/playbooks/common.yaml"
#   replayable = true
#   extra_vars = {
#     ansible_host                 = each.value.name
#     ansible_groups               = join(",", each.value.groups)
#     ansible_user                 = "saho"
#     ansible_ssh_private_key_file = "~/.ssh/pve"
#   }
# }
