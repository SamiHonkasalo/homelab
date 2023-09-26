terraform {
  required_version = ">= 1.5.7"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}
