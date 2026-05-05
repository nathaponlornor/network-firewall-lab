#############################################
# SD-WAN TGW Migration
# SD-WAN VPC + TGW Connect + BGP moved to sdwan_vpc.tf
# This file kept for SD-WAN RT + static routes
#############################################

# SD-WAN TGW Route Table
resource "aws_ec2_transit_gateway_route_table" "tgwrt_sdwan" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-SDWAN-TGW-RT-01" }
}
