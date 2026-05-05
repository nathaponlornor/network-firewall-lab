#############################################
# Network Firewall Rule Groups for Lab
# Same structure as production, adapted CIDRs
#############################################

# =============================================
# Rule Group 1: Block PRD ↔ NonProd
# =============================================
module "block_prd_nonprd" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-Block-PRD-NonPRD"
  description = "Block Connection between PRD and Non-PRD"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets   = []
    port_sets = []
  }

  stateful_rules = [
    { action = "DROP", header = { source = "10.100.32.0/19", destination = "10.100.192.0/19", source_port = "ANY", destination_port = "ANY", protocol = "IP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["20"] }, { keyword = "msg", settings = ["\"Block DEV→PRD\""] }] },
    { action = "DROP", header = { source = "10.100.192.0/19", destination = "10.100.32.0/19", source_port = "ANY", destination_port = "ANY", protocol = "IP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["30"] }, { keyword = "msg", settings = ["\"Block PRD→DEV\""] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}

# =============================================
# Rule Group 2: Database Security
# =============================================
module "database_security_rules" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-Database-Security"
  description = "Rules for Database access"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets = [
      { key = "DEV_DB", ip_set = { definition = ["10.100.32.160/27"] } },
      { key = "PRD_DB", ip_set = { definition = ["10.100.192.160/27"] } },
      { key = "DEV_BACKEND", ip_set = { definition = ["10.100.33.64/27"] } },
      { key = "PRD_BACKEND", ip_set = { definition = ["10.100.193.64/27"] } },
    ]
    port_sets = []
  }

  stateful_rules = [
    { action = "PASS", header = { source = "$DEV_BACKEND", destination = "$DEV_DB", source_port = "ANY", destination_port = "5432", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["1"] }, { keyword = "msg", settings = ["\"DEV Backend→DEV DB\""] }] },
    { action = "PASS", header = { source = "$PRD_BACKEND", destination = "$PRD_DB", source_port = "ANY", destination_port = "5432", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["2"] }, { keyword = "msg", settings = ["\"PRD Backend→PRD DB\""] }] },
    { action = "DROP", header = { source = "ANY", destination = "$DEV_DB,$PRD_DB", source_port = "ANY", destination_port = "ANY", protocol = "IP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["10"] }, { keyword = "msg", settings = ["\"Block all→DB\""] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}

# =============================================
# Rule Group 3: Domain Controller
# =============================================
module "domain_controller_rules" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-Domain-Controller"
  description = "Rules for Domain Controller communication"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets = [
      { key = "AWS_VPCS", ip_set = { definition = ["10.100.32.0/19", "10.100.192.0/19"] } },
      { key = "DC_VMS", ip_set = { definition = ["10.100.5.132/32", "10.100.5.148/32"] } },
    ]
    port_sets = []
  }

  stateful_rules = [
    { action = "PASS", header = { source = "$AWS_VPCS", destination = "$DC_VMS", source_port = "ANY", destination_port = "53,88,135,389,445,636", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["1"] }, { keyword = "msg", settings = ["\"VPC→DC TCP\""] }] },
    { action = "PASS", header = { source = "$AWS_VPCS", destination = "$DC_VMS", source_port = "ANY", destination_port = "53,88,123,389,445", protocol = "UDP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["2"] }, { keyword = "msg", settings = ["\"VPC→DC UDP\""] }] },
    { action = "PASS", header = { source = "$DC_VMS", destination = "$AWS_VPCS", source_port = "ANY", destination_port = "53,88,135,389,445,636", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["3"] }, { keyword = "msg", settings = ["\"DC→VPC TCP\""] }] },
    { action = "PASS", header = { source = "$DC_VMS", destination = "$AWS_VPCS", source_port = "ANY", destination_port = "53,88,123,389,445", protocol = "UDP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["4"] }, { keyword = "msg", settings = ["\"DC→VPC UDP\""] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}

# =============================================
# Rule Group 4: Internal Security (VPC Endpoints)
# =============================================
module "internal_security_rules" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-Internal-Security"
  description = "Allow internal communication within AWS"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets = [
      { key = "AWS_WORKLOAD", ip_set = { definition = ["10.100.32.0/19", "10.100.192.0/19"] } },
      { key = "SHARED_VPC", ip_set = { definition = ["10.100.5.128/25"] } },
    ]
    port_sets = []
  }

  stateful_rules = [
    { action = "PASS", header = { source = "$AWS_WORKLOAD", destination = "$SHARED_VPC", source_port = "ANY", destination_port = "443", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["10"] }, { keyword = "msg", settings = ["\"Workload→Shared 443\""] }] },
    { action = "PASS", header = { source = "$SHARED_VPC", destination = "$AWS_WORKLOAD", source_port = "ANY", destination_port = "443", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["20"] }, { keyword = "msg", settings = ["\"Shared→Workload 443\""] }] },
    { action = "PASS", header = { source = "$AWS_WORKLOAD", destination = "$SHARED_VPC", source_port = "ANY", destination_port = "53", protocol = "UDP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["30"] }, { keyword = "msg", settings = ["\"Workload→Shared DNS\""] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}

# =============================================
# Rule Group 5: External Net (Outbound Internet)
# =============================================
module "external_net_rules" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-External-Net"
  description = "Rules for outbound internet"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets = [
      { key = "AWS_WORKLOAD", ip_set = { definition = ["10.100.32.0/19", "10.100.192.0/19"] } },
      { key = "EXTERNAL_NET", ip_set = { definition = ["!10.0.0.0/8", "!172.16.0.0/12", "!192.168.0.0/16"] } },
    ]
    port_sets = []
  }

  stateful_rules = [
    { action = "PASS", header = { source = "$AWS_WORKLOAD", destination = "$EXTERNAL_NET", source_port = "ANY", destination_port = "443", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["10"] }, { keyword = "msg", settings = ["\"HTTPS outbound\""] }] },
    { action = "PASS", header = { source = "$AWS_WORKLOAD", destination = "$EXTERNAL_NET", source_port = "ANY", destination_port = "80", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["20"] }, { keyword = "msg", settings = ["\"HTTP outbound\""] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}

# =============================================
# Rule Group 6: Suricata Allow Flow Established
# =============================================
module "suricata_allow_flow_established" {
  source      = "../modules/fw_rule_group"
  name        = "Lab-Suricata-Allow-Flow"
  description = "Allow established flows"
  capacity    = 100
  type        = "STATEFUL"
  tags        = { Environment = "Lab", Owner = "NetworkTeam" }

  rule_variables = {
    ip_sets   = []
    port_sets = []
  }

  stateful_rules = [
    { action = "PASS", header = { source = "10.100.0.0/16", destination = "10.100.0.0/16", source_port = "ANY", destination_port = "ANY", protocol = "TCP", direction = "FORWARD" }, rule_option = [{ keyword = "sid", settings = ["1"] }, { keyword = "msg", settings = ["\"Allow internal TCP\""] }, { keyword = "flow", settings = ["established"] }] },
  ]
  stateful_rule_options = { rule_order = "STRICT_ORDER" }
}
