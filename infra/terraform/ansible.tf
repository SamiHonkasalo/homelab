resource "null_resource" "clear_know_hosts" {
  depends_on = [proxmox_vm_qemu.k8s_node, proxmox_vm_qemu.k8s_control_plane]
  triggers = {
    any_node_id          = join(",", [for node in proxmox_vm_qemu.k8s_node : node.id])
    any_control_plane_id = join(",", [for control_plane in proxmox_vm_qemu.k8s_control_plane : control_plane.id])
  }
  provisioner "local-exec" {
    command = "rm ~/.ssh/known_hosts"
  }
}

resource "ansible_host" "control_planes" {
  for_each = proxmox_vm_qemu.k8s_control_plane
  name     = each.value.default_ipv4_address
  groups   = ["control_planes"]
  variables = {
    ansible_user                 = "saho"
    ansible_ssh_private_key_file = "~/.ssh/pve"
    hostname                     = each.value.name
  }
}

resource "ansible_host" "nodes" {
  for_each = proxmox_vm_qemu.k8s_node
  name     = each.value.default_ipv4_address
  groups   = ["nodes"]
  variables = {
    ansible_user                 = "saho"
    ansible_ssh_private_key_file = "~/.ssh/pve"
    hostname                     = each.value.name
  }
}

# The ansible provisioner playbook resource is not that great
# Run the playbooks with local-exec
resource "null_resource" "ansible_playbook_common" {
  depends_on = [ansible_host.control_planes, ansible_host.nodes]
  lifecycle {
    replace_triggered_by = [ansible_host.control_planes, ansible_host.nodes]
  }
  triggers = {
    roles    = sha1(join("", [for f in fileset("${path.module}/../ansible/playbooks/roles/common", "*.yaml") : filesha1("${"${path.module}/../ansible/playbooks/roles/common"}/${f}")]))
    playbook = filesha1("${path.module}/../ansible/playbooks/common.yaml")
  }
  provisioner "local-exec" {
    command = "ansible-playbook --ssh-common-args='-o StrictHostKeyChecking=accept-new' -i ${path.module}/../ansible/inventory.yaml ${path.module}/../ansible/playbooks/common.yaml"
  }
}

resource "null_resource" "ansible_playbook_control_planes" {
  depends_on = [null_resource.ansible_playbook_common]
  lifecycle {
    replace_triggered_by = [ansible_host.control_planes]
  }
  triggers = {
    roles    = sha1(join("", [for f in fileset("${path.module}/../ansible/playbooks/roles/control_planes", "*.yaml") : filesha1("${"${path.module}/../ansible/playbooks/roles/control_planes"}/${f}")]))
    playbook = filesha1("${path.module}/../ansible/playbooks/control_planes.yaml")
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/../ansible/inventory.yaml ${path.module}/../ansible/playbooks/control_planes.yaml"
  }
}

resource "null_resource" "ansible_playbook_nodes" {
  depends_on = [null_resource.ansible_playbook_control_planes]
  lifecycle {
    replace_triggered_by = [ansible_host.nodes]
  }
  triggers = {
    roles    = sha1(join("", [for f in fileset("${path.module}/../ansible/playbooks/roles/nodes", "*.yaml") : filesha1("${"${path.module}/../ansible/playbooks/roles/nodes"}/${f}")]))
    playbook = filesha1("${path.module}/../ansible/playbooks/nodes.yaml")
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/../ansible/inventory.yaml ${path.module}/../ansible/playbooks/nodes.yaml"
  }
}
