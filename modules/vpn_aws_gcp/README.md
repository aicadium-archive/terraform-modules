# High-availability VPN connectivity between AWS and GCP

This Terraform module establishes a highly-available site-to-site VPN connection between GCP and AWS networks.


### Required variables

- `gcp_project_id` - Name of the GCP project which contains the GCP network.
- `gcp_network` - Name of the GCP network to which the router with the VPN tunnel peerings is attached to.
- `gcp_bgp_asn` - BGP ASN of the GCP network. This ASN should not clash with the AWS BGP ASN.
- `aws_bgp_asn` - BGP ASN of the AWS network. This ASN should not clash with the GCP BGP ASN.
- `aws_vpc_id` - AWS VPC ID

### Using an existing AWS VPN gateway

If you already have an existing VPN gateway attached to your AWS VPC, you can use it by specifying `use_existing_aws_vgw` as `true`.

### Connectivity diagram

```

                                        AWS VPC
                                           |
                                           |
                            (VPN gateway route propagations)
                                           |
                                           |
                                          AWS
            +---------------------- Virtual Private ----------------------+
            |                           Gateway                           |
            |                                                             |
           AWS                                                           AWS
     VPN connection A                                              VPN connection B
         a1   a2                                                       b1   b2
            |                                                             |
            |                                                             |
           AWS                                                           AWS
    Customer Gateway A                                            Customer Gateway B
            |                                                             |
            |                                                             |
            +------------------------------+------------------------------+
                                           |
                                           |
 AWS                                  (          )
- - - - - - - - - - - - - - - - - - - ( INTERNET ) - - - - - - - - - - - - - - - - - - -
 GCP                                  (          )
                                           |
                                           |
                                          GCP
                                        External
                                      VPN Gateway
                                      a1 a2 b1 b2
                                       |  |  |  |
                                       |  |  |  |
           +---------------------------+  |  |  +--------------------------+
           |                              |  |                             |
           |                    +---------+  +--------+                    |
           |                    |                     |                    |
          GCP                  GCP                   GCP                  GCP
      VPN Tunnel 1         VPN Tunnel 2          VPN Tunnel 3         VPN Tunnel 4
           |                    |                     |                    |
           |                    +--------+   +--------+                    |
           |                             |   |                             |
           +---------------------------+ |   | +---------------------------+
                                       | |   | |
                                       | |   | |
                                       if0   if1
                                          GCP
                                     HA VPN Gateway
                                           |
                                           |
                   (GCP Cloud Router with interfaces for each tunnel)
                                           |
                                           |
                                        GCP VPC

```


### Resources

GCP documentation on HA VPN connectivity:
- https://cloud.google.com/vpn/docs/concepts/topologies#aws_peer_gateways
- https://cloud.google.com/vpn/docs/how-to/creating-ha-vpn

AWS documentation on redundant VPN connectivity
- https://docs.aws.amazon.com/vpn/latest/s2svpn/VPNConnections.html
- https://aws.amazon.com/answers/networking/aws-multiple-data-center-ha-network-connectivity/
- https://docs.aws.amazon.com/vpc/latest/adminguide/Introduction.html#MultipleVPNConnections
