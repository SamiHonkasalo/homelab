variable "proxmox_api_url" {
  type = string
}
variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_template_name" {
  type    = string
  default = "ubuntu-2204-cloud"
}

variable "proxmox_target_node" {
  type    = string
  default = "pve-1"
}

variable "proxmox_cloud_init_path" {
  type    = string
  default = "user=local:snippets/cloud-init.yml"
}

variable "control_planes" {
  type = map(object({
    vmid    = number
    name    = string
    macaddr = string
  }))
  default = {
    "1" = {
      vmid    = 1001
      name    = "k8s-control-plane-1"
      macaddr = "A6:0F:D8:EA:26:71"
    }
  }
}

variable "nodes" {
  type = map(object({
    vmid    = number
    name    = string
    macaddr = string
  }))
  default = {
    "1" = {
      vmid    = 1002
      name    = "k8s-node-1"
      macaddr = "A6:0F:D8:EA:26:72"
    }
    "2" = {
      vmid    = 1003
      name    = "k8s-node-2"
      macaddr = "A6:0F:D8:EA:26:73"
    }
    "3" = {
      vmid    = 1004
      name    = "k8s-node-3"
      macaddr = "A6:0F:D8:EA:26:74"
    }
  }
}

