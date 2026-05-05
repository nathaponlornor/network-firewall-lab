#############################################
# SD-WAN TGW Migration: Placeholder
# YOU configure the SD-WAN appliance + BGP
#############################################

# SD-WAN VPC (create your own or use existing)
# resource "aws_vpc" "sdwan" {
#   cidr_block = "10.100.7.0/26"
#   tags       = { Name = "${var.project_name}-SDWAN-VPC" }
# }

# TGW Route Table for SD-WAN
resource "aws_ec2_transit_gateway_route_table" "tgwrt_sdwan" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-SDWAN-TGW-RT-01" }
}

# Uncomment when SD-WAN VPC is ready:

# resource "aws_ec2_transit_gateway_vpc_attachment" "sdwan_vpc_attachment" {
#   subnet_ids             = [<sdwan_tgw_subnet_b>, <sdwan_tgw_subnet_c>]
#   transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
#   vpc_id                 = aws_vpc.sdwan.id
#   appliance_mode_support = "enable"
#   tags = { Name = "${var.project_name}-SDWAN-TGW-ATT-01" }
# }

# resource "aws_ec2_transit_gateway_connect" "sdwan_connect" {
#   transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
#   transit_gateway_id      = aws_ec2_transit_gateway.lab_tgw.id
#   protocol                = "gre"
#   tags = { Name = "${var.project_name}-SDWAN-TGW-CONNECT-01" }
# }

# resource "aws_ec2_transit_gateway_connect_peer" "sdwan_bgp_peer" {
#   transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.sdwan_connect.id
#   peer_address                  = var.sdwan_appliance_private_ip
#   inside_cidr_blocks            = [var.sdwan_bgp_inside_cidr]
#   bgp_asn                       = var.sdwan_bgp_asn
#   tags = { Name = "${var.project_name}-SDWAN-BGP-PEER-01" }
# }

# resource "aws_ec2_transit_gateway_route_table_association" "sdwan_vpc_rt_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "sdwan_connect_rt_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.sdwan_connect.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
# }

# Propagate workload VPCs into SD-WAN RT
# resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_dev_propagation" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_prd_propagation" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
# }

# resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_shared_propagation" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
# }
