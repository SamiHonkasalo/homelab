# SaHo Homelab

Scripts and some IaC things related to my homelab setup.

Uses Terraform and Ansible to set up a kubernetes cluster on a local server running Proxmox

## Template setup

- ssh to the proxmox host
- run the following command:
```bash
  wget -O - https://raw.githubusercontent.com/SamiHonkasalo/homelab/main/proxmox/create-proxmox-template.sh | bash
```
This will create a proxmox template that uses a cloud-init config

## Infra setup

Note that the project cannot be run on a Windows machine due to Ansible. Use WSL.

1. Create credentials.auto.tfvars and add the required variables there.
   - Check credentials.sample.tfvars for reference
2. Make sure that terraform and ansible are installed
3. Make sure that [ansible terraform collection](https://galaxy.ansible.com/ui/repo/published/cloud/terraform/) is installed 

```bash
  terraform init
```

```bash
  terraform apply
```

## Cluster setup

TODO! (ArgoCD etc)