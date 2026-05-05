#############################################
# SD-WAN VPC + EC2 (FRRouting for BGP peering)
#############################################

resource "aws_vpc" "sdwan" {
  cidr_block           = "10.100.7.0/26"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-SDWAN-VPC" }
}

resource "aws_subnet" "sdwan_private_b" {
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = "10.100.7.0/28"
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-SDWAN-Private-Subnet-B" }
}

resource "aws_subnet" "sdwan_private_c" {
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = "10.100.7.16/28"
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-SDWAN-Private-Subnet-C" }
}

resource "aws_subnet" "sdwan_tgw_b" {
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = "10.100.7.32/28"
  availability_zone = "ap-southeast-7b"
  tags = { Name = "${var.project_name}-SDWAN-TGW-Subnet-B" }
}

resource "aws_subnet" "sdwan_tgw_c" {
  vpc_id            = aws_vpc.sdwan.id
  cidr_block        = "10.100.7.48/28"
  availability_zone = "ap-southeast-7c"
  tags = { Name = "${var.project_name}-SDWAN-TGW-Subnet-C" }
}

resource "aws_route_table" "sdwan_private" {
  vpc_id = aws_vpc.sdwan.id
  tags   = { Name = "${var.project_name}-SDWAN-Private-RT" }
}

resource "aws_route" "sdwan_to_tgw" {
  route_table_id         = aws_route_table.sdwan_private.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment]
}

resource "aws_route_table_association" "sdwan_private_b" {
  subnet_id      = aws_subnet.sdwan_private_b.id
  route_table_id = aws_route_table.sdwan_private.id
}

resource "aws_route_table_association" "sdwan_private_c" {
  subnet_id      = aws_subnet.sdwan_private_c.id
  route_table_id = aws_route_table.sdwan_private.id
}

#############################################
# TGW VPC Attachment for SD-WAN
#############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "sdwan_vpc_attachment" {
  subnet_ids             = [aws_subnet.sdwan_tgw_b.id, aws_subnet.sdwan_tgw_c.id]
  transit_gateway_id     = aws_ec2_transit_gateway.lab_tgw.id
  vpc_id                 = aws_vpc.sdwan.id
  appliance_mode_support = "enable"
  tags = { Name = "${var.project_name}-SDWAN-TGW-ATT-01" }
}

#############################################
# TGW Connect (GRE for BGP)
#############################################
resource "aws_ec2_transit_gateway_connect" "sdwan_connect" {
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
  transit_gateway_id      = aws_ec2_transit_gateway.lab_tgw.id
  protocol                = "gre"
  tags = { Name = "${var.project_name}-SDWAN-TGW-CONNECT-01" }
}

#############################################
# TGW Connect Peer (BGP with FRR EC2)
#############################################
resource "aws_ec2_transit_gateway_connect_peer" "sdwan_bgp_peer" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.sdwan_connect.id
  peer_address                  = aws_instance.sdwan_frr.private_ip
  inside_cidr_blocks            = [var.sdwan_bgp_inside_cidr]
  bgp_asn                       = var.sdwan_bgp_asn
  tags = { Name = "${var.project_name}-SDWAN-BGP-PEER-01" }
}

#############################################
# SD-WAN RT Associations + Propagations
#############################################
resource "aws_ec2_transit_gateway_route_table_association" "sdwan_vpc_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.sdwan_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
}

resource "aws_ec2_transit_gateway_route_table_association" "sdwan_connect_rt_association" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_connect.sdwan_connect.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
}

# Propagate workload VPCs into SD-WAN RT
resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_dev_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.dev_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_prd_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.prd_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "sdwan_rt_shared_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.shared_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgwrt_sdwan.id
}

#############################################
# EC2: FRRouting (BGP daemon)
#############################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "sdwan_frr" {
  name_prefix = "${var.project_name}-sdwan-frr-"
  vpc_id      = aws_vpc.sdwan.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16", "169.254.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-SDWAN-FRR-SG" }
}

resource "aws_instance" "sdwan_frr" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.sdwan_private_b.id
  vpc_security_group_ids = [aws_security_group.sdwan_frr.id]
  source_dest_check      = false

  user_data = <<-EOF
    #!/bin/bash
    yum install -y frr
    sed -i 's/bgpd=no/bgpd=yes/' /etc/frr/daemons
    cat > /etc/frr/frr.conf << 'FRRCONF'
    frr version 8.4
    frr defaults traditional
    hostname sdwan-lab
    !
    router bgp ${var.sdwan_bgp_asn}
     bgp router-id 10.100.7.10
     neighbor 169.254.100.1 remote-as ${var.tgw_amazon_side_asn}
     !
     address-family ipv4 unicast
      network 10.0.0.0/8
      network 172.16.0.0/12
      neighbor 169.254.100.1 activate
     exit-address-family
    !
    FRRCONF
    systemctl enable frr
    systemctl start frr
  EOF

  tags = { Name = "${var.project_name}-SDWAN-FRR-EC2" }
}
