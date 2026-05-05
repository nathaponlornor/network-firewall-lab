variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "stateful_rule_group_references" {
  type = list(object({
    resource_arn = string
    priority     = optional(number)
    override = optional(object({
      action = optional(string)
    }))
  }))
  default = []
}

variable "stateless_rule_group_references" {
  type = list(object({
    resource_arn = string
    priority     = number
  }))
  default = []
}

variable "stateful_default_actions" {
  type    = list(string)
  default = ["aws:drop_strict"]
}

variable "stateless_default_actions" {
  type    = list(string)
  default = ["aws:forward_to_sfe"]
}

variable "stateless_fragment_default_actions" {
  type    = list(string)
  default = ["aws:forward_to_sfe"]
}

variable "stateful_engine_options" {
  type = object({
    rule_order              = optional(string)
    stream_exception_policy = optional(string)
  })
  default = null
}
