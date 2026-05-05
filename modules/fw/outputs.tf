output "id" {
  value = module.firewall.id
}

output "arn" {
  value = module.firewall.arn
}

output "status" {
  value = module.firewall.status
}

output "tgw_firewall_attachment_id" {
  description = "The Transit Gateway Attachment ID created by the Network Firewall"
  value       = module.firewall.status[0].transit_gateway_attachment_sync_states[0].attachment_id
}

output "logging_configuration_id" {
  value = module.firewall.logging_configuration_id
}
