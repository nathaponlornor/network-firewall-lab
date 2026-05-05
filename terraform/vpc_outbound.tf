#############################################
# Outbound VPC (NAT Gateway for internet access)
# Same pattern as production Outbound VPC
#############################################

resource "aws_vpc" "outbound" {
  cidr_block           = "10.100.3.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-Outbound-VPC" }
}

# Public subnet (IGW → NAT)
resource "aws_subnet" "outbound_public_b" {
  vpc_id            = aws_vpc.outbound.id
  cidr_block        = "10.100.3.0/27"
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-Outbound-Public-Subnet-B" }
}

resource "aws_subnet" "outbound_public_c" {
  vpc_id            = aws_vpc.outbound.id
  cidr_block        = "10.100.3.32/27"
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-Outbound-Public-Subnet-C" }
}

# TGW subnet
resource "aws_subnet" "outbound_tgw_b" {
  vpc_id            = aws_vpc.outbound.id
  cidr_block        = "10.100.3.64/28"
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-Outbound-TGW-Subnet-B" }
}

resource "aws_subnet" "outbound_tgw_c" {
  vpc_id            = aws_vpc.outbound.id
  cidr_block        = "10.100.3.80/28"
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-Outbound-TGW-Subnet-C" }
}

# Internet Gateway
resource "aws_internet_gateway" "outbound" {
  vpc_id = aws_vpc.outbound.id
  tags   = { Name = "${var.project_name}-Outbound-IGW" }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-NAT-EIP" }
}

# NAT Gateway
resource "aws_nat_gateway" "outbound" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.outbound_public_b.id
  tags          = { Name = "${var.project_name}-NAT-GW" }
  depends_on    = [aws_internet_gateway.outbound]
}

# Public Route Table (IGW)
resource "aws_route_table" "outbound_public" {
  vpc_id = aws_vpc.outbound.id
  tags   = { Name = "${var.project_name}-Outbound-Public-RT" }
}

resource "aws_route" "outbound_public_igw" {
  route_table_id         = aws_route_table.outbound_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.outbound.id
}

resource "aws_route" "outbound_public_to_tgw" {
  route_table_id         = aws_route_table.outbound_public.id
  destination_cidr_block = "10.100.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.outbound_vpc_attachment]
}

resource "aws_route_table_association" "outbound_public_b" {
  subnet_id      = aws_subnet.outbound_public_b.id
  route_table_id = aws_route_table.outbound_public.id
}

resource "aws_route_table_association" "outbound_public_c" {
  subnet_id      = aws_subnet.outbound_public_c.id
  route_table_id = aws_route_table.outbound_public.id
}

# TGW Route Table (return traffic to workloads via TGW)
resource "aws_route_table" "outbound_tgw" {
  vpc_id = aws_vpc.outbound.id
  tags   = { Name = "${var.project_name}-Outbound-TGW-RT" }
}

resource "aws_route" "outbound_tgw_to_nat" {
  route_table_id         = aws_route_table.outbound_tgw.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.outbound.id
}

resource "aws_route" "outbound_tgw_to_tgw" {
  route_table_id         = aws_route_table.outbound_tgw.id
  destination_cidr_block = "10.100.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.outbound_vpc_attachment]
}

resource "aws_route_table_association" "outbound_tgw_b" {
  subnet_id      = aws_subnet.outbound_tgw_b.id
  route_table_id = aws_route_table.outbound_tgw.id
}

resource "aws_route_table_association" "outbound_tgw_c" {
  subnet_id      = aws_subnet.outbound_tgw_c.id
  route_table_id = aws_route_table.outbound_tgw.id
}

#############################################
# TGW Attachment for Outbound VPC
#############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "outbound_vpc_attachment" {
  subnet_ids         = [aws_subnet.outbound_tgw_b.id, aws_subnet.outbound_tgw_c.id]
  transit_gateway_id = aws_ec2_transit_gateway.lab_tgw.id
  vpc_id             = aws_vpc.outbound.id
  tags = { Name = "${var.project_name}-Outbound-TGW-ATT-01" }
}

# Associate Outbound to COMMON RT
resource "aws_ec2_transit_gateway_route_table_association" "outbound_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_common.id
}

# Propagate Outbound into Firewall RT
resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_firewall_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.outbound_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_firewall.id
}
