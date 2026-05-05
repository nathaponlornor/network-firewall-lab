resource "aws_networkfirewall_firewall_policy" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags

  firewall_policy {
    stateful_default_actions           = var.stateful_default_actions
    stateless_default_actions          = var.stateless_default_actions
    stateless_fragment_default_actions = var.stateless_fragment_default_actions

    dynamic "stateful_rule_group_reference" {
      for_each = var.stateful_rule_group_references
      content {
        resource_arn = stateful_rule_group_reference.value.resource_arn
        priority     = try(stateful_rule_group_reference.value.priority, null)

        dynamic "override" {
          for_each = stateful_rule_group_reference.value.override != null ? [stateful_rule_group_reference.value.override] : []
          content {
            action = try(override.value.action, null)
          }
        }
      }
    }

    dynamic "stateless_rule_group_reference" {
      for_each = var.stateless_rule_group_references
      content {
        resource_arn = stateless_rule_group_reference.value.resource_arn
        priority     = stateless_rule_group_reference.value.priority
      }
    }

    dynamic "stateful_engine_options" {
      for_each = var.stateful_engine_options != null ? [var.stateful_engine_options] : []
      content {
        rule_order              = try(stateful_engine_options.value.rule_order, null)
        stream_exception_policy = try(stateful_engine_options.value.stream_exception_policy, null)
      }
    }
  }
}
