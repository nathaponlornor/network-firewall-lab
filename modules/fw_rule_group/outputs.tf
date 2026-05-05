output "rule_group_arn" {
  value       = aws_networkfirewall_rule_group.this.arn
  description = "ARN of the rule group"
}
