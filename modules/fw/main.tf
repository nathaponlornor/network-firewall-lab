module "firewall" {
  source = "terraform-aws-modules/network-firewall/aws//modules/firewall"

  create = var.create

  # Firewall Properties
  delete_protection                   = var.delete_protection
  availability_zone_change_protection = var.availability_zone_change_protection
  description                         = var.description
  firewall_policy_arn               = var.firewall_policy_arn
  firewall_policy_change_protection = var.firewall_policy_change_protection
  name                              = var.name
  subnet_change_protection          = var.subnet_change_protection

  transit_gateway_id        = var.transit_gateway_id
  availability_zone_mapping = var.availability_zone_mapping

  # Logging
  create_logging_configuration             = var.create_logging_configuration
  logging_configuration_destination_config = var.logging_configuration_destination_config

  tags = var.tags
}
