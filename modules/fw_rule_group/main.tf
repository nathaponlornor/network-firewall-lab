resource "aws_networkfirewall_rule_group" "this" {
  name        = var.name
  description = var.description
  capacity    = var.capacity
  type        = var.type
  tags        = var.tags

  rule_group {
    rule_variables {
      dynamic "ip_sets" {
        for_each = var.rule_variables.ip_sets
        content {
          key = ip_sets.value.key
          dynamic "ip_set" {
            for_each = [ip_sets.value.ip_set]
            content {
              definition = ip_set.value.definition
            }
          }
        }
      }

      dynamic "port_sets" {
        for_each = var.rule_variables.port_sets
        content {
          key = port_sets.value.key
          dynamic "port_set" {
            for_each = [port_sets.value.port_set]
            content {
              definition = port_set.value.definition
            }
          }
        }
      }
    }

    rules_source {
      rules_string = var.rules_string

      dynamic "rules_source_list" {
        for_each = length(var.rules_source_list) > 0 ? var.rules_source_list : []
        content {
          generated_rules_type = rules_source_list.value.generated_rules_type
          target_types         = rules_source_list.value.target_types
          targets              = rules_source_list.value.targets
        }
      }

      dynamic "stateful_rule" {
        for_each = var.stateful_rules != null ? var.stateful_rules : []
        content {
          action = stateful_rule.value.action
          header {
            source           = stateful_rule.value.header.source
            destination      = stateful_rule.value.header.destination
            source_port      = stateful_rule.value.header.source_port
            destination_port = stateful_rule.value.header.destination_port
            protocol         = stateful_rule.value.header.protocol
            direction        = stateful_rule.value.header.direction
          }

          dynamic "rule_option" {
            for_each = stateful_rule.value.rule_option
            content {
              keyword  = rule_option.value.keyword
              settings = rule_option.value.settings
            }
          }
        }
      }
    }

    stateful_rule_options {
      rule_order = var.stateful_rule_options.rule_order
    }
  }
}
