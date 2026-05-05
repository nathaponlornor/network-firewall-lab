variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "capacity" {
  type = number
}

variable "type" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "rule_variables" {
  type    = any
  default = {}
}

variable "rules_source_list" {
  type = list(object({
    generated_rules_type = string
    target_types         = list(string)
    targets              = list(string)
  }))
  default = []
}

variable "rules_string" {
  type    = string
  default = null
}

variable "stateful_rules" {
  type = list(object({
    action = string
    header = object({
      source           = string
      destination      = string
      source_port      = string
      destination_port = string
      protocol         = string
      direction        = string
    })
    rule_option = list(object({
      keyword  = string
      settings = list(string)
    }))
  }))
  default = []
}

variable "stateful_rule_options" {
  type = object({
    rule_order = string
  })
  default = {
    rule_order = "STRICT_ORDER"
  }
}
