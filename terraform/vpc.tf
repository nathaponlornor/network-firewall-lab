#############################################
# VPCs for Lab Environment
#############################################

# =============================================
# DEV VPC (simulates workload DEV)
# =============================================
resource "aws_vpc" "dev" {
  cidr_block           = var.vpc_dev_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-DEV-VPC" }
}

resource "aws_subnet" "dev_app_b" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(var.vpc_dev_cidr, 5, 0) # /24
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-DEV-App-Subnet-B" }
}

resource "aws_subnet" "dev_app_c" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(var.vpc_dev_cidr, 5, 1) # /24
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-DEV-App-Subnet-C" }
}

resource "aws_subnet" "dev_tgw_b" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(var.vpc_dev_cidr, 9, 240) # /28
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-DEV-TGW-Subnet-B" }
}

resource "aws_subnet" "dev_tgw_c" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(var.vpc_dev_cidr, 9, 241) # /28
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-DEV-TGW-Subnet-C" }
}

resource "aws_route_table" "dev_private" {
  vpc_id = aws_vpc.dev.id
  tags   = { Name = "${var.project_name}-DEV-Private-RT" }
}

resource "aws_route" "dev_to_tgw" {
  route_table_id         = aws_route_table.dev_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment]
}

resource "aws_route_table_association" "dev_app_b" {
  subnet_id      = aws_subnet.dev_app_b.id
  route_table_id = aws_route_table.dev_private.id
}

resource "aws_route_table_association" "dev_app_c" {
  subnet_id      = aws_subnet.dev_app_c.id
  route_table_id = aws_route_table.dev_private.id
}

# =============================================
# PRD VPC (simulates workload PRD)
# =============================================
resource "aws_vpc" "prd" {
  cidr_block           = var.vpc_prd_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-PRD-VPC" }
}

resource "aws_subnet" "prd_app_b" {
  vpc_id            = aws_vpc.prd.id
  cidr_block        = cidrsubnet(var.vpc_prd_cidr, 5, 0) # /24
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-PRD-App-Subnet-B" }
}

resource "aws_subnet" "prd_app_c" {
  vpc_id            = aws_vpc.prd.id
  cidr_block        = cidrsubnet(var.vpc_prd_cidr, 5, 1) # /24
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-PRD-App-Subnet-C" }
}

resource "aws_subnet" "prd_tgw_b" {
  vpc_id            = aws_vpc.prd.id
  cidr_block        = cidrsubnet(var.vpc_prd_cidr, 9, 240) # /28
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-PRD-TGW-Subnet-B" }
}

resource "aws_subnet" "prd_tgw_c" {
  vpc_id            = aws_vpc.prd.id
  cidr_block        = cidrsubnet(var.vpc_prd_cidr, 9, 241) # /28
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-PRD-TGW-Subnet-C" }
}

resource "aws_route_table" "prd_private" {
  vpc_id = aws_vpc.prd.id
  tags   = { Name = "${var.project_name}-PRD-Private-RT" }
}

resource "aws_route" "prd_to_tgw" {
  route_table_id         = aws_route_table.prd_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment]
}

resource "aws_route_table_association" "prd_app_b" {
  subnet_id      = aws_subnet.prd_app_b.id
  route_table_id = aws_route_table.prd_private.id
}

resource "aws_route_table_association" "prd_app_c" {
  subnet_id      = aws_subnet.prd_app_c.id
  route_table_id = aws_route_table.prd_private.id
}

# =============================================
# Shared Infra VPC (VPC Endpoints, AD)
# =============================================
resource "aws_vpc" "shared" {
  cidr_block           = var.vpc_shared_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-Shared-Infra-VPC" }
}

resource "aws_subnet" "shared_b" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = cidrsubnet(var.vpc_shared_cidr, 2, 0) # /27
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-Shared-Subnet-B" }
}

resource "aws_subnet" "shared_c" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = cidrsubnet(var.vpc_shared_cidr, 2, 1) # /27
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-Shared-Subnet-C" }
}

resource "aws_subnet" "shared_tgw_b" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = cidrsubnet(var.vpc_shared_cidr, 2, 2) # /27
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-Shared-TGW-Subnet-B" }
}

resource "aws_subnet" "shared_tgw_c" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = cidrsubnet(var.vpc_shared_cidr, 2, 3) # /27
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-Shared-TGW-Subnet-C" }
}

resource "aws_route_table" "shared_private" {
  vpc_id = aws_vpc.shared.id
  tags   = { Name = "${var.project_name}-Shared-Private-RT" }
}

resource "aws_route" "shared_to_tgw" {
  route_table_id         = aws_route_table.shared_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment]
}

resource "aws_route_table_association" "shared_b" {
  subnet_id      = aws_subnet.shared_b.id
  route_table_id = aws_route_table.shared_private.id
}

resource "aws_route_table_association" "shared_c" {
  subnet_id      = aws_subnet.shared_c.id
  route_table_id = aws_route_table.shared_private.id
}
