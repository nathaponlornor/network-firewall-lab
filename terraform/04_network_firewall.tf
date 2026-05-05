#############################################
# Network Firewall Policy + Firewall
# TGW attachment mode (same as production)
#############################################

module "lab_policy" {
  source = "../modules/fw_policy"

  name        = "${var.project_name}-FW-Policy-01"
  description = "Firewall policy for Lab environment"

  stateful_default_actions           = ["aws:drop_established_app_layer", "aws:alert_strict"]
  stateless_default_actions          = ["aws:forward_to_sfe"]
  stateless_fragment_default_actions = ["aws:forward_to_sfe"]
  stateful_engine_options            = { rule_order = "STRICT_ORDER", stream_exception_policy = null }

  stateful_rule_group_references = [
    { priority = 1, resource_arn = "arn:aws:network-firewall:ap-southeast-7:aws-managed:stateful-rulegroup/AbusedLegitBotNetCommandAndControlDomainsStrictOrder", override = null },
    { priority = 2, resource_arn = "arn:aws:network-firewall:ap-southeast-7:aws-managed:stateful-rulegroup/BotNetCommandAndControlDomainsStrictOrder", override = null },
    { priority = 3, resource_arn = "arn:aws:network-firewall:ap-southeast-7:aws-managed:stateful-rulegroup/AbusedLegitMalwareDomainsStrictOrder", override = null },
    { priority = 4, resource_arn = "arn:aws:network-firewall:ap-southeast-7:aws-managed:stateful-rulegroup/MalwareDomainsStrictOrder", override = null },
    { priority = 5, resource_arn = module.block_prd_nonprd.rule_group_arn, override = null },
    { priority = 6, resource_arn = module.database_security_rules.rule_group_arn, override = null },
    { priority = 7, resource_arn = module.domain_controller_rules.rule_group_arn, override = null },
    { priority = 8, resource_arn = module.internal_security_rules.rule_group_arn, override = null },
    { priority = 9, resource_arn = module.external_net_rules.rule_group_arn, override = null },
    { priority = 10, resource_arn = module.suricata_allow_flow_established.rule_group_arn, override = null },
  ]
}

module "lab_fw" {
  source = "../modules/fw"

  create              = true
  name                = "${var.project_name}-FW-01"
  firewall_policy_arn = module.lab_policy.firewall_policy_arn
  transit_gateway_id  = aws_ec2_transit_gateway.lab_tgw.id

  availability_zone_mapping = [
    { availability_zone_id = "apse7-az1" },
    { availability_zone_id = "apse7-az2" }
  ]

  delete_protection                   = false
  availability_zone_change_protection = false
  description                         = "Lab Network Firewall - ap-southeast-7"
  firewall_policy_change_protection   = false
  subnet_change_protection            = false

  create_logging_configuration = true
  logging_configuration_destination_config = [
    { log_type = "FLOW", log_destination_type = "CloudWatchLogs", log_destination = { logGroup = aws_cloudwatch_log_group.nfw_flow_logs.name } },
    { log_type = "ALERT", log_destination_type = "CloudWatchLogs", log_destination = { logGroup = aws_cloudwatch_log_group.nfw_alert_logs.name } },
  ]
}

resource "aws_cloudwatch_log_group" "nfw_flow_logs" {
  name              = "Lab-NetworkFirewall-FLOW-Log-Group"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "nfw_alert_logs" {
  name              = "Lab-NetworkFirewall-ALERT-Log-Group"
  retention_in_days = 30
}
