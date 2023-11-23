# Proxmox VM Template Setup using Packer and Ansible

This repository contains a Packer template and Ansible playbook to create a Proxmox VM template with the following features:

- Debian 12 (Bookworm)
- SSH access using a public key
- Docker
- Docker Compose
- Auto updates

## Pre-requisites

- Installed packer
- Installed ansible
- Proxmox host with API access

## Usage

1. Clone this repository
2. Create a ssh key pair for packer to use to temporarily ssh into the VM during setup. Or alternatively use password authentication.
3. Edit the cloud.cfg and preseed.cfg files in the 'http' directories to incude passwords for users and SSH keys
4. Rename credentials.pkr.hcl.example to credentials.pkr.hcl, enter your credentials and the Proxmox host
5. Edit the packer.json file to include the correct VM ID and the path to your ssh key, etc.
6. Initialize packer with `packer init .`
7. Run `make validate` to validate the template and `make build` to build the template


## License

See the LICENSE file.