provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a Static IP for Classic VPN
resource "google_compute_address" "vpn-static-ip" {
  count   = var.env == "np" ? 1 : 0
  name    = var.classicvpnname
  project = var.project_id
}

# Create a Classic VPN
resource "google_compute_vpn_gateway" "mss-vpn-gateway" {
  count   = var.env == "np" ? 1 : 0
  name    = var.classicvpnname
  project = var.project_id
  network = var.network_svc
}

# VPN Forwarding Rule ESP
resource "google_compute_forwarding_rule" "vpn-fr-esp-classic" {
  count       = var.env == "np" ? 1 : 0
  name        = "vpn-gateway-fr-esp"
  project     = var.project_id
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn-static-ip[count.index].address
  target      = google_compute_vpn_gateway.mss-vpn-gateway[count.index].id
}

# VPN Forwarding Rule UDP 500
resource "google_compute_forwarding_rule" "vpn-fr-udp500-classic" {
  count       = var.env == "np" ? 1 : 0
  name        = "vpn-gateway-fr-udp500"
  project     = var.project_id
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn-static-ip[count.index].address
  target      = google_compute_vpn_gateway.mss-vpn-gateway[count.index].id
}

# VPN Forwarding Rule UDP 4500
resource "google_compute_forwarding_rule" "vpn-fr-udp4500-classic" {
  count       = var.env == "np" ? 1 : 0
  name        = "vpn-gateway-fr-udp4500"
  project     = var.project_id
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn-static-ip[count.index].address
  target      = google_compute_vpn_gateway.mss-vpn-gateway[count.index].id
}
# Generate a Pre-Shared Key (PSK) for the VPN tunnel
resource "random_password" "psk" {
  count   = var.env == "np" ? 1 : 0
  length  = 16    # Adjust the length as necessary
  special = false # Ensure no special characters for PSK
}

# Create a secret in Secret Manager
resource "google_secret_manager_secret" "vpn_psk_secret" {
  count = var.env == "np" ? 1 : 0

  secret_id = "vpn-psk-${var.env}"
  
  replication {
    user_managed {
      replicas {
        location = var.region  # Define location for the secret
      }
    }
  }
}

# Add the generated PSK as a secret version
resource "google_secret_manager_secret_version" "vpn_psk_secret_version" {
  count = var.env == "np" ? 1 : 0

  secret      = google_secret_manager_secret.vpn_psk_secret[0].id
  secret_data = random_password.psk[0].result  # Use the PSK generated above
}

# Step 6: Create the VPN Tunnel
resource "google_compute_vpn_tunnel" "vpn_tunnel" {
  count   = var.env == "np" ? 1 : 0
  depends_on = [
    google_compute_forwarding_rule.vpn-fr-esp-classic,
    google_compute_forwarding_rule.vpn-fr-udp500-classic,
    google_compute_forwarding_rule.vpn-fr-udp4500-classic,
    google_compute_vpn_gateway.mss-vpn-gateway
  ]

  name               = "mss-vpn-tunnel"
  region             = var.region
  target_vpn_gateway = google_compute_vpn_gateway.mss-vpn-gateway[count.index].id
  peer_ip            = var.peer_ip # Replace with the peer's public IP

  shared_secret      = random_password.psk[0].result # Use the generated PSK

  ike_version        = 2 # Use IKEv2

  # Local (GCP) and remote network IP ranges
  local_traffic_selector  = var.subnet_ip   # Local GCP subnet as list
  remote_traffic_selector = var.vpn_ip_range # Remote network IP ranges as list
}

