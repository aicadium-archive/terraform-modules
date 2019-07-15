resource "google_compute_external_vpn_gateway" "from_aws" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "ext-gateway-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"

  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = var.gcp_external_vpn_gateway_desc

  interface {
    id         = 0
    ip_address = aws_vpn_connection.a.tunnel1_address
  }

  interface {
    id         = 1
    ip_address = aws_vpn_connection.a.tunnel2_address
  }

  interface {
    id         = 2
    ip_address = aws_vpn_connection.b.tunnel1_address
  }

  interface {
    id         = 3
    ip_address = aws_vpn_connection.b.tunnel2_address
  }
}

resource "google_compute_ha_vpn_gateway" "a" {
  provider = "google-beta"
  project  = var.gcp_project_id
  name     = "vpn-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region   = var.gcp_region
  network  = var.gcp_network
}


# If the peer gateway has two interfaces, then configuring two tunnels, one
# from each peer interface to each HA VPN gateway interface, meets the
# requirements for the 99.99% SLA

# Tunnel 1: HA VPN interface 0 to AWS interface 0

resource "google_compute_vpn_tunnel" "tunnel1" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "vpn-tunnel1-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region  = var.gcp_region

  vpn_gateway           = google_compute_ha_vpn_gateway.a.self_link
  vpn_gateway_interface = 0

  peer_external_gateway           = google_compute_external_vpn_gateway.from_aws.self_link
  peer_external_gateway_interface = 0

  shared_secret = aws_vpn_connection.a.tunnel1_preshared_key
  router        = google_compute_router.a.name
}


# Tunnel 2: HA VPN interface 0 to AWS interface 1

resource "google_compute_vpn_tunnel" "tunnel2" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "vpn-tunnel2-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region  = var.gcp_region

  vpn_gateway           = google_compute_ha_vpn_gateway.a.self_link
  vpn_gateway_interface = 0

  peer_external_gateway           = google_compute_external_vpn_gateway.from_aws.self_link
  peer_external_gateway_interface = 1

  shared_secret = aws_vpn_connection.a.tunnel2_preshared_key
  router        = google_compute_router.a.name
}


# Tunnel 3: HA VPN interface 1 to AWS interface 2

resource "google_compute_vpn_tunnel" "tunnel3" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "vpn-tunnel3-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region  = var.gcp_region

  vpn_gateway           = google_compute_ha_vpn_gateway.a.self_link
  vpn_gateway_interface = 1

  peer_external_gateway           = google_compute_external_vpn_gateway.from_aws.self_link
  peer_external_gateway_interface = 2

  shared_secret = aws_vpn_connection.b.tunnel1_preshared_key
  router        = google_compute_router.a.name
}


# Tunnel 4: HA VPN interface 1 to AWS interface 3

resource "google_compute_vpn_tunnel" "tunnel4" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "vpn-tunnel4-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region  = var.gcp_region

  vpn_gateway           = google_compute_ha_vpn_gateway.a.self_link
  vpn_gateway_interface = 1

  peer_external_gateway           = google_compute_external_vpn_gateway.from_aws.self_link
  peer_external_gateway_interface = 3

  shared_secret = aws_vpn_connection.b.tunnel2_preshared_key
  router        = google_compute_router.a.name
}


# Router A

resource "google_compute_router" "a" {
  provider = "google-beta"

  project = var.gcp_project_id
  name    = "router-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region  = var.gcp_region
  network = var.gcp_network

  bgp {
    asn = var.gcp_bgp_asn
  }
}

# BGP routing peer for Tunnel 1

resource "google_compute_router_interface" "tunnel1" {
  name   = "if-tunnel1-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  ip_range   = "${aws_vpn_connection.a.tunnel1_cgw_inside_address}/${var.vpn_tunnel_cidr}"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_peer" "tunnel1" {
  name   = "peer-tunnel1-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  peer_ip_address = aws_vpn_connection.a.tunnel1_vgw_inside_address
  peer_asn        = aws_vpn_connection.a.tunnel1_bgp_asn

  interface = google_compute_router_interface.tunnel1.name
}

# BGP routing peer for Tunnel 2

resource "google_compute_router_interface" "tunnel2" {
  name   = "if-tunnel2-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  ip_range   = "${aws_vpn_connection.a.tunnel2_cgw_inside_address}/${var.vpn_tunnel_cidr}"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "tunnel2" {
  name   = "peer-tunnel2-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  peer_ip_address = aws_vpn_connection.a.tunnel2_vgw_inside_address
  peer_asn        = aws_vpn_connection.a.tunnel2_bgp_asn

  interface = google_compute_router_interface.tunnel2.name
}

# BGP routing peer for Tunnel 3

resource "google_compute_router_interface" "tunnel3" {
  name   = "if-tunnel3-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  ip_range   = "${aws_vpn_connection.b.tunnel1_cgw_inside_address}/${var.vpn_tunnel_cidr}"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel3.name
}

resource "google_compute_router_peer" "tunnel3" {
  name   = "peer-tunnel3-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  peer_ip_address = aws_vpn_connection.b.tunnel1_vgw_inside_address
  peer_asn        = aws_vpn_connection.b.tunnel1_bgp_asn

  interface = google_compute_router_interface.tunnel3.name
}

# BGP routing peer for Tunnel 4

resource "google_compute_router_interface" "tunnel4" {
  name   = "if-tunnel4-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  ip_range   = "${aws_vpn_connection.b.tunnel2_cgw_inside_address}/${var.vpn_tunnel_cidr}"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel4.name
}

resource "google_compute_router_peer" "tunnel4" {
  name   = "peer-tunnel4-${var.gcp_network_resource_name}-to-${var.aws_network_resource_name}"
  region = google_compute_router.a.region

  router = google_compute_router.a.name

  peer_ip_address = aws_vpn_connection.b.tunnel2_vgw_inside_address
  peer_asn        = aws_vpn_connection.b.tunnel2_bgp_asn

  interface = google_compute_router_interface.tunnel4.name
}
