variable "project_name" {
  description = "Project name prefix for all resources"
  type        = string
  default     = "Lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

# VPC CIDRs
variable "vpc_dev_cidr" {
  description = "DEV VPC CIDR"
  type        = string
  default     = "10.100.32.0/19"
}

variable "vpc_prd_cidr" {
  description = "PRD VPC CIDR"
  type        = string
  default     = "10.100.192.0/19"
}

variable "vpc_shared_cidr" {
  description = "Shared Infra VPC CIDR"
  type        = string
  default     = "10.100.5.128/25"
}

# TGW
variable "tgw_amazon_side_asn" {
  description = "TGW Amazon Side ASN"
  type        = number
  default     = 65001
}

# SD-WAN (fill these when ready)
variable "sdwan_appliance_private_ip" {
  description = "SD-WAN appliance private IP for BGP peering"
  type        = string
  default     = "10.100.7.10"
}

variable "sdwan_bgp_inside_cidr" {
  description = "BGP inside CIDR for TGW Connect peer"
  type        = string
  default     = "169.254.100.0/29"
}

variable "sdwan_bgp_asn" {
  description = "BGP ASN of SD-WAN appliance"
  type        = string
  default     = "65100"
}
