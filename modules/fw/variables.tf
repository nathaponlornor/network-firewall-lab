variable "create" {
  type    = bool
  default = true
}

variable "name" {
  type = string
}

variable "firewall_policy_arn" {
  type = string
}

variable "transit_gateway_id" {
  type = string
}

variable "availability_zone_mapping" {
  type = list(object({
    availability_zone_id = string
  }))
  default = null
}

variable "delete_protection" {
  type    = bool
  default = false
}

variable "availability_zone_change_protection" {
  type    = bool
  default = false
}

variable "description" {
  type    = string
  default = null
}

variable "firewall_policy_change_protection" {
  type    = bool
  default = false
}

variable "subnet_change_protection" {
  type    = bool
  default = false
}

variable "encryption_configuration" {
  type    = list(any)
  default = null
}

variable "create_logging_configuration" {
  type    = bool
  default = false
}

variable "logging_configuration_destination_config" {
  type    = list(any)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
