locals {
  aws_vpn_gateway_id = var.use_existing_aws_vgw ? data.aws_vpn_gateway.existing[0].id : aws_vpn_gateway.a[0].id
}

resource "aws_vpn_gateway" "a" {
  count = var.use_existing_aws_vgw ? 0 : 1

  # A VPC can only have one VPN gateway attached
  vpc_id          = var.aws_vpc_id
  amazon_side_asn = var.aws_bgp_asn
}

resource "aws_vpn_gateway_route_propagation" "a" {
  count = length(data.aws_route_tables.tables.ids)

  vpn_gateway_id = local.aws_vpn_gateway_id
  route_table_id = element(tolist(data.aws_route_tables.tables.ids), count.index)
}


# AWS Virtual Private Gateway A

resource "aws_customer_gateway" "a" {
  bgp_asn    = var.gcp_bgp_asn
  ip_address = google_compute_ha_vpn_gateway.a.vpn_interfaces[0].ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "a" {
  vpn_gateway_id      = local.aws_vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.a.id
  type                = "ipsec.1"
  static_routes_only  = false
}


# AWS Virtual Private Gateway B

resource "aws_customer_gateway" "b" {
  bgp_asn    = var.gcp_bgp_asn
  ip_address = google_compute_ha_vpn_gateway.a.vpn_interfaces[1].ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "b" {
  vpn_gateway_id      = local.aws_vpn_gateway_id
  customer_gateway_id = aws_customer_gateway.b.id
  type                = "ipsec.1"
  static_routes_only  = false
}
