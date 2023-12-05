resource proxmox_virtual_environment_vm traefik-debian-12 {
  count = 1
  vm_id = 125
  name = "traefik-debian-12"
  description = "Traefik on Debian 12"
  node_name = "${var.proxmox_node}"

  tags = ["terraform", "traefik", "debian-12"]

  clone {
    vm_id = 1111
    full = true
  }

  on_boot = true
  agent {
    enabled = true
    trim = true
  }

  machine = "q35"
  operating_system {
    type = "l26"
  }

  cpu {
    cores = 4
    sockets = 1
    type = "host"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
    model = "virtio"
    mac_address = "${var.traefik_macaddr}"
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.traefik_ipconfig0}"
        gateway = "${var.network_gateway}"
      }
    }
  }

  scsi_hardware = "virtio-scsi-pci"
  disk {
    interface    = "virtio0"
    datastore_id = "${var.traefik_storage}"
    size         = 20
    discard      = "ignore"
  }

  connection {
    type        = "ssh"
    user        = "serveradmin"
    private_key = file("~/.ssh/id_rsa_packer")
    host        = "${var.traefik_host}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/traefik",
      "mkdir ~/traefik/data",
      "touch ~/traefik/data/acme.json",
      "chmod 600 ~/traefik/data/acme.json",
    ]
  }
}

#################### PROVISIONING ####################
# Potentially dangerous... so occassionally do this manually
# resource null_resource update-and-provision-traefik {
#   depends_on = [
#     proxmox_virtual_environment_vm.traefik-debian-12
#   ]

#   triggers = {
#     update_packages = var.FORCE_UPDATE_PACKAGES
#     dir_sha256 = sha256(join("", [for f in fileset("${var.traefik_config_dir}", "*"): filesha256("${var.traefik_config_dir}/${f}")]))
#     last_run_month = data.external.current_month_and_year.result.now
#   }

#   connection {
#     type        = "ssh"
#     user        = "serveradmin"
#     private_key = file("~/.ssh/id_rsa_packer")
#     host        = "${var.traefik_host}"
#   }

#   provisioner "file" {
#     source      = "${var.traefik_config_dir}/docker-compose.yml"
#     destination = "/home/serveradmin/docker-compose.yml"
#   }

#   provisioner "file" {
#     source      = "${var.traefik_config_dir}/config.yml"
#     destination = "/home/serveradmin/traefik/config.yml"
#   }

#   provisioner "file" {
#     source      = "${var.traefik_config_dir}/traefik.yml"
#     destination = "/home/serveradmin/traefik/data/traefik.yml"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update",
#       "sudo apt upgrade -y",
#       "docker compose pull",
#       "docker compose up --force-recreate --remove-orphans --build -d",
#       "docker image prune -f",
#     ]
#   }
# }
