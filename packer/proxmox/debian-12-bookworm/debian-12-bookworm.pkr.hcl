# Debian 12 (Bookworm) on Proxmox
# ---
# Packer Template to create a Debian 12 (Bookworm) VM Template on Proxmox with Cloud-Init Integration

packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_api_token_id" {
    type = string
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}

variable "proxmox_node" {
    type = string
}

variable "proxmox_iso_storage" {
    type = string
}

# Resource Definiation for the VM Template
source "proxmox" "debian-12-bookworm" {
 
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_api_token_id}"
    token = "${var.proxmox_api_token_secret}"
    # (Optional) Skip TLS Verification
    # insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "${var.proxmox_node}"
    vm_id = "1111"
    os = "l26"
    machine = "q35"
    vm_name = "debian-12-bookworm"
    template_description = "Debian 12 Image"

    # VM OS Settings
    # (Option 1) Local ISO File
    # iso_file = "local:iso/debian-12.2.0-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    iso_url = "http://ftp.acc.umu.se/debian-cd/12.2.0/amd64/iso-cd/debian-12.2.0-amd64-netinst.iso"
    iso_checksum = "23ab444503069d9ef681e3028016250289a33cc7bab079259b73100daee0af66"
    iso_storage_pool = "${var.proxmox_iso_storage}"
    unmount_iso = true

    # VM System Settings
    qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "20G"
        format = "raw"
        storage_pool = "local-lvm"
        storage_pool_type = "lvm"
        type = "virtio"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "4096" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local-lvm"

    # PACKER Boot Commands
    boot_command = ["<esc><wait>auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>"]
    boot_wait = "8s"

    # PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    # http_bind_address = "0.0.0.0"
    # http_port_min = 8802
    # http_port_max = 8802

    ssh_username = "root"

    # (Option 1) Add your Password here
    # ssh_password = "your-password"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_rsa_packer"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "20m"
}

# Build Definition to create the VM Template
build {
    name = "debian-12-bookworm"
    sources = ["source.proxmox.debian-12-bookworm"]

    # Using ansible playbooks to configure debian
    provisioner "ansible" {
        playbook_file    = "./ansible/debian_config.yml"
        use_proxy        = false
        user             = "root"
        ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]
        extra_arguments  = ["--extra-vars", "ansible_ssh_private_key_file=~/.ssh/id_rsa_packer"]
    }

    # Copy default cloud-init config
    provisioner "file" {
        destination = "/etc/cloud/cloud.cfg"
        source      = "http/cloud.cfg"
    }

    # Copy Proxmox cloud-init config
    provisioner "file" {
        destination = "/etc/cloud/cloud.cfg.d/99-pve.cfg"
        source      = "http/99-pve.cfg"
    }

    # Add additional provisioning scripts here
    # ...
}