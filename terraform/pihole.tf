resource proxmox_virtual_environment_vm pihole-debian-12 {
  count = 1
  vm_id = 123
  name = "pihole-debian-12"
  description = "PiHole on Debian 12"
  node_name = "${var.proxmox_node}"

  tags = ["terraform", "pihole", "debian-12"]

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
    mac_address = "${var.pihole_macaddr}"
    firewall = true
  }
  initialization {
    ip_config {
      ipv4 {
        address = "${var.pihole_ipconfig0}"
        gateway = "${var.network_gateway}"
      }
    }
  }

  scsi_hardware = "virtio-scsi-pci"
  disk {
    interface    = "virtio0"
    datastore_id = "${var.pihole_storage}"
    size         = 20
    discard      = "ignore"
  }
}
#################### PROVISIONING ####################
resource null_resource update-and-provision-pihole {
  depends_on = [
    proxmox_virtual_environment_vm.pihole-debian-12
  ]

  triggers = {
    update_packages = var.FORCE_UPDATE_PACKAGES
    dir_sha256 = sha256(join("", [for f in fileset("../configs/pihole", "*"): filesha256("../configs/pihole/${f}")]))
    last_run_month = data.external.current_month_and_year.result.now
  }

  connection {
    type        = "ssh"
    user        = "serveradmin"
    private_key = file("~/.ssh/id_rsa_packer")
    host        = "${var.pihole_host}"
  }

  provisioner "file" {
    source      = "../configs/pihole/docker-compose.yml"
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
