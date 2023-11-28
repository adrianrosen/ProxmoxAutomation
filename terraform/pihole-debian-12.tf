variable "proxmox_node" {
  type = string
}

variable "pihole_macaddr" {
  type = string
}

variable "pihole_ipconfig0" {
  type = string
}

variable "pihole_host" {
  type = string
}

variable "pihole_storage" {
  type = string
}

resource "proxmox_vm_qemu" "pihole-debian-12" {
  count = 1
  name = "pihole-debian-12"
  desc = "PiHole on Debian 12"
  vmid = 123
  target_node = "${var.proxmox_node}"
  qemu_os = "l26"

  agent = 1

  clone = "debian-12-bookworm"
  cores = 4
  sockets = 1
  memory = 4096
  cpu = "host"
  scsihw = "virtio-scsi-pci"
  
  network {
    bridge = "vmbr0"
    model = "virtio"
    macaddr = "${var.pihole_macaddr}"
  }

  os_type = "cloud-init"
  ipconfig0 = "${var.pihole_ipconfig0}"

  disk {
    storage = "${var.pihole_storage}"
    size = "20G"
    type = "virtio"
    discard = "ignore"
    backup = true
  }

  lifecycle {
    ignore_changes = [
      disk.0.cache,
      disk.0.iops,
      disk.0.iops_max,
      disk.0.iops_max_length,
      disk.0.iops_rd,
      disk.0.iops_rd_max,
      disk.0.iops_rd_max_length,
      disk.0.iops_wr,
      disk.0.iops_wr_max,
      disk.0.iops_wr_max_length,
      disk.0.iothread,
      disk.0.mbps,
      disk.0.mbps_rd,
      disk.0.mbps_rd_max,
      disk.0.mbps_wr,
      disk.0.mbps_wr_max,
      disk.0.replicate
    ]
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
      "docker compose pull",
      "docker compose up --force-recreate --remove-orphans --build -d",
      "docker image prune -f",
    ]
  }
}
