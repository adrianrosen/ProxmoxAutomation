resource "proxmox_vm_qemu" "pihole-debian-12" {
  count = 1
  name = "pihole-debian-12"
  desc = "PiHole on Debian 12"
  vmid = 123
  target_node = "${var.proxmox_node}"
  qemu_os = "l26"
  onboot = true

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
    #   disk["cache"],
    #   disk["iops"],
      disk["iops_max"],
      disk["iops_max_length"],
      disk["iops_rd"],
      disk["iops_rd_max"],
      disk["iops_rd_max_length"],
      disk["iops_wr"],
      disk["iops_wr_max"],
      disk["iops_wr_max_length"],
      disk["iothread"],
      disk["mbps"],
      disk["mbps_rd"],
      disk["mbps_rd_max"],
      disk["mbps_wr"],
      disk["mbps_wr_max"],
      disk["replicate"],
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


resource "proxmox_vm_qemu" "traefik-debian-12" {
  count = 1
  name = "traefik-debian-12"
  desc = "Traefik on Debian 12"
  vmid = 125
  target_node = "${var.proxmox_node}"
  qemu_os = "l26"
  onboot = true

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
    macaddr = "${var.traefik_macaddr}"
  }

  os_type = "cloud-init"
  ipconfig0 = "${var.traefik_ipconfig0}"

  disk {
    storage = "${var.traefik_storage}"
    size = "20G"
    type = "virtio"
    discard = "ignore"
    backup = true
  }

  lifecycle {
    ignore_changes = [
      disk
    ]
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
    ]
  }

  provisioner "file" {
    source      = "../configs/traefik/docker-compose.yml"
    destination = "/home/serveradmin/docker-compose.yml"
  }

  provisioner "file" {
    source      = "../configs/traefik/config.yml"
    destination = "/home/serveradmin/traefik/config.yml"
  }

  provisioner "file" {
    source      = "../configs/traefik/traefik.yml"
    destination = "/home/serveradmin/traefik/data/traefik.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "docker compose pull",
      "docker compose up --force-recreate --remove-orphans --build -d",
      "docker image prune -f",
    ]
  }
}

resource "proxmox_vm_qemu" "tdarr-debian-12" {
  count = 1
  name = "tdarr-debian-12"
  desc = "Tdarr on Debian 12"
  vmid = 129
  target_node = "${var.proxmox_node}"
  qemu_os = "l26"
  onboot = true

  agent = 1

  clone = "debian-12-bookworm"
  cores = 4
  sockets = 1
  memory = 8192
  cpu = "host"
  scsihw = "virtio-scsi-pci"
  
  network {
    bridge = "vmbr0"
    model = "virtio"
    macaddr = "${var.tdarr_macaddr}"
  }

  os_type = "cloud-init"
  ipconfig0 = "${var.tdarr_ipconfig0}"

  disk {
    storage = "${var.tdarr_storage}"
    size = "20G"
    type = "virtio"
    discard = "ignore"
    backup = true
  }

  # hostpci {
  #   host = "0000:01:00.0"
  #   pcie = 1
  # }

  lifecycle {
    ignore_changes = [
      disk
    ]
  }

  connection {
    type        = "ssh"
    user        = "serveradmin"
    private_key = file("~/.ssh/id_rsa_packer")
    host        = "${var.tdarr_host}"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo add-apt-repository -y contrib non-free-firmware non-free",
      "sudo apt update",
      "sudo apt install -y nvidia-driver firmware-misc-nonfree linux-image-amd64 nvidia-smi nvidia-settings",
      "sudo reboot",
    ]
  }
}


resource "null_resource" "configure-tdarr" {
  depends_on = [
    proxmox_vm_qemu.tdarr-debian-12
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "serveradmin"
    private_key = file("~/.ssh/id_rsa_packer")
    host        = "${var.tdarr_host}"
  }

  provisioner "file" {
    source      = "../configs/tdarr/docker-compose.yml"
    destination = "/home/serveradmin/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg",
      "curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "sudo apt-get update",
      "sudo apt-get install -y nvidia-container-toolkit",
      "docker compose pull",
      "docker compose up --force-recreate --remove-orphans --build",
      "docker image prune -f",
    ]
  }
}
