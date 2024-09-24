provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a VPN gateway
resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = var.vpn_gateway_name
  network = var.network
  region  = var.region
}

# Create a VPN tunnel
resource "google_compute_vpn_tunnel" "vpn_tunnel" {
  name                  = var.vpn_tunnel_name
  region                = var.region
  vpn_gateway           = google_compute_vpn_gateway.vpn_gateway.id
  peer_ip               = var.peer_ip
  shared_secret         = var.shared_secret
  ike_version           = 2
  target_vpn_gateway    = google_compute_vpn_gateway.vpn_gateway.id
  local_traffic_selector = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector
}

# Static route for the VPN
resource "google_compute_route" "vpn_static_route" {
  count                 = length(var.remote_traffic_selector)
  name                  = "vpn-static-route-${count.index}"
  network               = var.network
  dest_range            = element(var.remote_traffic_selector, count.index)
  next_hop_vpn_tunnel   = google_compute_vpn_tunnel.vpn_tunnel.id
  priority              = 1000
}

# Optional: Firewall rule to allow traffic through the VPN
resource "google_compute_firewall" "vpn_firewall_rule" {
  name    = "allow-vpn-traffic"
  network = var.network

  allow {
    protocol = "all"
  }

  source_ranges = var.local_traffic_selector
  target_tags   = var.vpn_firewall_target_tags
}
