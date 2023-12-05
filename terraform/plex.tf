resource proxmox_virtual_environment_vm plex-debian-12 {
  count = 1
  vm_id = 126
  name = "plex-debian-12"
  description = "Plex on Debian 12"
  node_name = "${var.proxmox_node}"

  tags = ["terraform", "plex", "debian-12"]

  clone {
    vm_id = 1111
    full = true
  }

  on_boot = false
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
    mac_address = "${var.plex_macaddr}"
  }
  initialization {
    dns {
      server = "${var.network_dns}"
    }
    ip_config {
      ipv4 {
        address = "${var.plex_ipconfig0}"
        gateway = "${var.network_gateway}"
      }
    }
  }

  scsi_hardware = "virtio-scsi-pci"
  disk {
    interface    = "virtio0"
    datastore_id = "${var.plex_storage}"
    size         = 20
    discard      = "ignore"
  }
}
#################### PROVISIONING ####################
resource null_resource update-and-provision-plex {
  depends_on = [
    proxmox_virtual_environment_vm.plex-debian-12,
    # proxmox_virtual_environment_vm.pihole-debian-12
  ]

  triggers = {
    update_packages = var.FORCE_UPDATE_PACKAGES
    dir_sha256 = sha256(join("", [for f in fileset("../configs/plex", "*"): filesha256("../configs/plex/${f}")]))
    last_run_month = data.external.current_month_and_year.result.now
  }

  connection {
    type        = "ssh"
    user        = "serveradmin"
    private_key = file("~/.ssh/id_rsa_packer")
    host        = "${var.plex_host}"
  }

  provisioner "file" {
    source      = "../configs/plex/docker-compose.yml"
    destination = "/home/serveradmin/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "docker compose pull",
      "docker compose up --force-recreate --remove-orphans --build -d",
      "docker image prune -f",
    ]
  }
}
