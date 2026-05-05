#############################################
# VPC Endpoints for SSM (Session Manager)
# Required for EC2 in private subnets
#############################################

locals {
  ssm_services = ["ssm", "ssmmessages", "ec2"]
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints_dev" {
  name_prefix = "${var.project_name}-vpce-dev-"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_dev_cidr]
  }

  tags = { Name = "${var.project_name}-VPCE-DEV-SG" }
}

resource "aws_security_group" "vpc_endpoints_prd" {
  name_prefix = "${var.project_name}-vpce-prd-"
  vpc_id      = aws_vpc.prd.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_prd_cidr]
  }

  tags = { Name = "${var.project_name}-VPCE-PRD-SG" }
}

resource "aws_security_group" "vpc_endpoints_sdwan" {
  name_prefix = "${var.project_name}-vpce-sdwan-"
  vpc_id      = aws_vpc.sdwan.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.100.7.0/26"]
  }

  tags = { Name = "${var.project_name}-VPCE-SDWAN-SG" }
}

# DEV VPC Endpoints
resource "aws_vpc_endpoint" "dev_ssm" {
  for_each = toset(local.ssm_services)

  vpc_id              = aws_vpc.dev.id
  service_name        = "com.amazonaws.ap-southeast-7.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.dev_app_b.id, aws_subnet.dev_app_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_dev.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-DEV-${each.value}" }
}

# PRD VPC Endpoints
resource "aws_vpc_endpoint" "prd_ssm" {
  for_each = toset(local.ssm_services)

  vpc_id              = aws_vpc.prd.id
  service_name        = "com.amazonaws.ap-southeast-7.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.prd_app_b.id, aws_subnet.prd_app_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_prd.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-PRD-${each.value}" }
}

# SD-WAN VPC Endpoints (for FRR EC2)
resource "aws_vpc_endpoint" "sdwan_ssm" {
  for_each = toset(local.ssm_services)

  vpc_id              = aws_vpc.sdwan.id
  service_name        = "com.amazonaws.ap-southeast-7.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [aws_subnet.sdwan_private_b.id, aws_subnet.sdwan_private_c.id]
  security_group_ids  = [aws_security_group.vpc_endpoints_sdwan.id]
  private_dns_enabled = true

  tags = { Name = "${var.project_name}-SDWAN-${each.value}" }
}
