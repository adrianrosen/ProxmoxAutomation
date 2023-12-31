################ Global ################
variable "FORCE_UPDATE_PACKAGES" {
  type = string
  default = "something to make it update"
}
variable "proxmox_node" {
  type = string
}
variable "network_gateway" {
  type = string
}
variable "network_dns" {
  type = string
}
################ Plex ################
variable "plex_macaddr" {
  type = string
}
variable "plex_ipconfig0" {
  type = string
}
variable "plex_host" {
  type = string
}
variable "plex_storage" {
  type = string
}
variable "plex_config_dir" {
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
variable "pihole_config_dir" {
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
variable "traefik_config_dir" {
  type = string
}