#############################################
# Transit Gateway
#############################################
resource "aws_ec2_transit_gateway" "lab_tgw" {
  description                     = "Lab TGW for Firewall testing"
  amazon_side_asn                 = var.tgw_amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  transit_gateway_cidr_blocks     = ["169.254.100.0/24"]
  tags = { Name = "${var.project_name}-TGW-01" }
}

#############################################
# TGW VPC Attachments
#############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "dev_vpc_attachment" {
  subnet_ids         = [aws_subnet.dev_tgw_b.id, aws_subnet.dev_tgw_c.id]
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  vpc_id             = aws_vpc.dev.id
  tags = { Name = "${var.project_name}-DEV-TGW-ATT-01" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prd_vpc_attachment" {
  subnet_ids         = [aws_subnet.prd_tgw_b.id, aws_subnet.prd_tgw_c.id]
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  vpc_id             = aws_vpc.prd.id
  tags = { Name = "${var.project_name}-PRD-TGW-ATT-01" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_vpc_attachment" {
  subnet_ids         = [aws_subnet.shared_tgw_b.id, aws_subnet.shared_tgw_c.id]
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  vpc_id             = aws_vpc.shared.id
  tags = { Name = "${var.project_name}-Shared-TGW-ATT-01" }
}

#############################################
# TGW Route Tables
#############################################
resource "aws_ec2_transit_gateway_route_table" "tgwrt_common" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-Spoke-Common-TGW-RT-01" }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_nonprod" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-Spoke-NONPRD-TGW-RT-01" }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_prod" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-Spoke-PRD-TGW-RT-01" }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_workload" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-Spoke-Workload-TGW-RT-01" }
}

resource "aws_ec2_transit_gateway_route_table" "tgwrt_firewall" {
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  tags = { Name = "${var.project_name}-Firewall-TGW-RT-01" }
}

#############################################
# Associate: Shared Infra → COMMON RT
#############################################
resource "aws_ec2_transit_gateway_route_table_association" "shared_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
}

#############################################
# Associate: DEV → NONPROD RT (before cutover)
# Comment out and use workload RT for cutover
#############################################
resource "aws_ec2_transit_gateway_route_table_association" "dev_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_nonprod.id
}

# CUTOVER: Uncomment below, comment above
# resource "aws_ec2_transit_gateway_route_table_association" "dev_rt_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
# }

#############################################
# Associate: PRD → PROD RT (before cutover)
#############################################
resource "aws_ec2_transit_gateway_route_table_association" "prd_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_prod.id
}

# CUTOVER: Uncomment below, comment above
# resource "aws_ec2_transit_gateway_route_table_association" "prd_rt_association" {
#   transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
# }

#############################################
# Propagations: NONPROD RT
#############################################
resource "aws_ec2_transit_gateway_route_table_propagation" "dev_nonprod_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_nonprod.id
}

#############################################
# Propagations: PROD RT
#############################################
resource "aws_ec2_transit_gateway_route_table_propagation" "prd_prod_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_prod.id
}

#############################################
# Propagations: COMMON RT
#############################################
resource "aws_ec2_transit_gateway_route_table_propagation" "shared_common_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
}

#############################################
# Propagations: Firewall RT (all VPCs)
#############################################
resource "aws_ec2_transit_gateway_route_table_propagation" "dev_firewall_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_firewall.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prd_firewall_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_firewall.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "shared_firewall_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_firewall.id
}

#############################################
# Static Routes: NONPROD RT
#############################################
resource "aws_ec2_transit_gateway_route" "nonprod_to_shared" {
  destination_cidr_block         = var.vpc_shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_nonprod.id
}

resource "aws_ec2_transit_gateway_route" "nonprod_to_prd_blackhole" {
  destination_cidr_block         = var.vpc_prd_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_nonprod.id
  blackhole                      = true
}

#############################################
# Static Routes: PROD RT
#############################################
resource "aws_ec2_transit_gateway_route" "prod_to_shared" {
  destination_cidr_block         = var.vpc_shared_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_prod.id
}

resource "aws_ec2_transit_gateway_route" "prod_to_dev_blackhole" {
  destination_cidr_block         = var.vpc_dev_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_prod.id
  blackhole                      = true
}

#############################################
# Static Routes: COMMON RT
#############################################
resource "aws_ec2_transit_gateway_route" "common_to_dev" {
  destination_cidr_block         = var.vpc_dev_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
}

resource "aws_ec2_transit_gateway_route" "common_to_prd" {
  destination_cidr_block         = var.vpc_prd_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
}

#############################################
# Static Routes: WORKLOAD RT → all via Firewall
#############################################
resource "aws_ec2_transit_gateway_route" "workload_default_to_firewall" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = module.lab_fw.tgw_firewall_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
}

resource "aws_ec2_transit_gateway_route" "workload_to_shared_via_firewall" {
  destination_cidr_block         = var.vpc_shared_cidr
  transit_gateway_attachment_id  = module.lab_fw.tgw_firewall_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
}

resource "aws_ec2_transit_gateway_route" "workload_to_dev_via_firewall" {
  destination_cidr_block         = var.vpc_dev_cidr
  transit_gateway_attachment_id  = module.lab_fw.tgw_firewall_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
}

resource "aws_ec2_transit_gateway_route" "workload_to_prd_via_firewall" {
  destination_cidr_block         = var.vpc_prd_cidr
  transit_gateway_attachment_id  = module.lab_fw.tgw_firewall_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_workload.id
}

#############################################
# Associate: Firewall attachment → Firewall RT
#############################################
resource "aws_ec2_transit_gateway_route_table_association" "firewall_rt_association" {
  transit_gateway_attachment_id  = module.lab_fw.tgw_firewall_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_firewall.id
}
