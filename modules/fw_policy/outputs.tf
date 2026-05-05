output "firewall_policy_arn" {
  description = "The ARN of the firewall policy"
  value       = aws_networkfirewall_firewall_policy.this.arn
}
