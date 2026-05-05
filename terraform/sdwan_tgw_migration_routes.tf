#############################################
# Phase 3: Static routes to replace SD-WAN propagation
# Uncomment per Wave when SD-WAN BGP is UP
#############################################

locals {
  # Simulated on-prem prefixes (for lab testing)
  sdwan_onprem_prefixes = [
    "10.0.0.0/8",
    "172.16.0.0/12",
  ]
}

#############################################
# Wave 3.1: COMMON RT
#############################################

# resource "aws_ec2_transit_gateway_route" "sdwan_common_rt" {
#   for_each                       = toset(local.sdwan_onprem_prefixes)
#   destination_cidr_block         = each.value
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
# }

#############################################
# Wave 3.2: NONPROD RT
#############################################

# resource "aws_ec2_transit_gateway_route" "sdwan_nonprod_rt" {
#   for_each                       = toset(local.sdwan_onprem_prefixes)
#   destination_cidr_block         = each.value
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_nonprod.id
# }

#############################################
# Wave 3.3: PROD RT
#############################################

# resource "aws_ec2_transit_gateway_route" "sdwan_prod_rt" {
#   for_each                       = toset(local.sdwan_onprem_prefixes)
#   destination_cidr_block         = each.value
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_prod.id
# }
