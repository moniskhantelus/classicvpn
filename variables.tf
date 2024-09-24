variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "network" {
  description = "VPC network for the VPN"
  type        = string
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway"
  type        = string
}

variable "vpn_tunnel_name" {
  description = "Name of the VPN tunnel"
  type        = string
}

variable "peer_ip" {
  description = "Public IP address of the peer VPN gateway"
  type        = string
}

variable "shared_secret" {
  description = "Shared secret for VPN tunnel authentication"
  type        = string
}

variable "local_traffic_selector" {
  description = "CIDR blocks for local traffic"
  type        = list(string)
}

variable "remote_traffic_selector" {
  description = "CIDR blocks for remote traffic"
  type        = list(string)
}

variable "vpn_firewall_target_tags" {
  description = "Firewall target tags for the VPN"
  type        = list(string)
}
