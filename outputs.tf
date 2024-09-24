output "vpn_gateway_name" {
  value = google_compute_vpn_gateway.vpn_gateway.name
}

output "vpn_tunnel_name" {
  value = google_compute_vpn_tunnel.vpn_tunnel.name
}

output "vpn_gateway_ip" {
  value = google_compute_vpn_gateway.vpn_gateway.self_link
}
