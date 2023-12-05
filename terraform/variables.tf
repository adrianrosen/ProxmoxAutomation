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
variable "tdarr_cache_storage" {
  type = string
}