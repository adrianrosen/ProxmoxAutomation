variable "proxmox_node" {
  type = string
}
################ Pihole ################
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
################ Traefik ################
variable "traefik_macaddr" {
  type = string
}

variable "traefik_ipconfig0" {
  type = string
}

variable "traefik_host" {
  type = string
}

variable "traefik_storage" {
  type = string
}
################ Tdarr ################
variable "tdarr_macaddr" {
  type = string
}

variable "tdarr_ipconfig0" {
  type = string
}

variable "tdarr_host" {
  type = string
}

variable "tdarr_storage" {
  type = string
}