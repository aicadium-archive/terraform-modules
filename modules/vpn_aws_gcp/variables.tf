variable "gcp_region" {
  description = "Default region for GCP"
  default     = "asia-southeast1"
}

variable "gcp_project_id" {
  description = "Name of the GCP project which contains the GCP network"
}

variable "gcp_external_vpn_gateway_desc" {
  description = "Description of external VPN gateway"
  default     = "External VPN gateways to AWS cluster"
}

variable "aws_network_resource_name" {
  description = "Name of the AWS network referenced in the GCP resources to be created"
  default     = "aws"
}

variable "gcp_network_resource_name" {
  description = "Name of the GCP network referenced in the GCP resources to be created"
  default     = "gcp"
}

variable "gcp_network" {
  description = "Name of the GCP network to which the router with the VPN tunnel peerings is attached to"
}

variable "vpn_tunnel_cidr" {
  description = "The CIDR block of the inside IP addresses for the VPN tunnels"
  default     = "30"
}

variable "gcp_bgp_asn" {
  description = "BGP ASN of the GCP network. This ASN should not clash with the AWS BGP ASN."
  default     = 65000
}

variable "aws_bgp_asn" {
  description = "BGP ASN of the AWS network. This ASN should not clash with the GCP BGP ASN."
  default     = 65001
}

variable "aws_vpc_id" {
  description = "AWS VPC ID"
}
