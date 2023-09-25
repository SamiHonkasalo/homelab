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
variable "worker_nodes" {
  type = map(object({
    vmid    = number
    name    = string
    macaddr = string
    ip      = string
  }))
  default = {
    "1" = {
      vmid    = 1002
      name    = "k8s-node-1"
      macaddr = "A6:0F:D8:EA:26:72"
      ip      = "192.168.0.212"
    }
    "2" = {
      vmid    = 1003
      name    = "k8s-node-2"
      macaddr = "A6:0F:D8:EA:26:73"
      ip      = "192.168.0.213"
    }
  }
}

