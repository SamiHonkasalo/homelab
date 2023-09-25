locals {
  clone       = "ubuntu-2204-cloud"
  target_node = "pve-1"
  cicustom    = "user=local:snippets/cloud-init.yml"
  control = {
    name    = "k8s-controller"
    macaddr = "A6:0F:D8:EA:26:71"
    ip      = "192.168.0.211"
  }
  nodes = [
    {
      name    = "k8s-node-1"
      macaddr = "A6:0F:D8:EA:26:72"
      ip      = "192.168.0.212"
    },
    {
      name    = "k8s-node-2"
      macaddr = "A6:0F:D8:EA:26:73"
      ip      = "192.168.0.213"
    }
  ]
}

resource "proxmox_vm_qemu" "k8s_control" {
  name        = local.control.name
  desc        = "Kubernetes control plane"
  target_node = local.target_node
  clone       = local.clone
  vmid        = "1001"
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

  cicustom  = local.cicustom
  ipconfig0 = "ip=dhcp"

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    macaddr  = local.control.macaddr
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

resource "null_resource" "init_control" {
  depends_on = [proxmox_vm_qemu.k8s_control]
  lifecycle {
    replace_triggered_by = [proxmox_vm_qemu.k8s_control]
  }
  connection {
    type        = "ssh"
    user        = "saho"
    private_key = file("~/.ssh/pve")
    host        = local.control.ip
  }

  # Need to wait for cloud-init to finish apt install before doing anything else
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "Start-Sleep -s 120"
  }


  # Set correct hostname
  provisioner "remote-exec" {
    when = create
    inline = [
      "echo '127.0.0.1 ${local.control.name}' | sudo tee -a /etc/hosts",
      "sudo hostnamectl set-hostname ${local.control.name}",
    ]
  }

  # Setup 
  provisioner "file" {
    source      = "scripts/01_setup.sh"
    destination = "/tmp/01_setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/01_setup.sh",
      "sudo /tmp/01_setup.sh",
      "exit 0"
    ]
  }

  # Reboot
  provisioner "remote-exec" {
    inline = [
      "sudo shutdown -r +0",
      "exit 0"
    ]
  }

  # Install k8s 
  provisioner "file" {
    source      = "scripts/02_install_k8s.sh"
    destination = "/tmp/02_install_k8s.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/02_install_k8s.sh",
      "sudo /tmp/02_install_k8s.sh",
      "exit 0"
    ]
  }

  # Initialize control plane
  provisioner "file" {
    source      = "scripts/03_init_control.sh"
    destination = "/tmp/03_init_control.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/03_init_control.sh",
      "sudo /tmp/03_init_control.sh",
      "exit 0"
    ]
  }

  # Get the join script
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOF
      rm ./scripts/03_join.sh
      ssh saho@${local.control.ip} -o "UserKnownHostsFile=/dev/null" -o StrictHostKeyChecking=no -i ~/.ssh/pve "sudo kubeadm token create --print-join-command" >> ./scripts/03_join.sh
    EOF
  }

  # Get kubeconfig
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOF
      scp -i ~/.ssh/pve -r saho@${local.control.ip}~/.kube/config ~/.kube/config
    EOF
  }
}

