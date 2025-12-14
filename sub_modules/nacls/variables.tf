variable "namespace" {
  type        = string
  description = "Project namespace"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags to apply to resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where subnets will be created"
}

variable "nacl_type" {
  description = "Type of subnet (public, private, or database)"
  type        = string
}

variable "subnets" {
  type        = any
  description = "List of available subnets for the specified NACL type"
}

variable "nacls" {
  type = map(object({
    is_bidirectional = optional(bool, true)
    common_rules     = optional(list(string), [])
    inbound_rules = optional(list(object({
      rule_number     = number
      protocol        = string
      rule_action     = string
      cidr_block      = optional(string)
      ipv6_cidr_block = optional(string)
      from_port       = number
      to_port         = number
    })), [])
    outbound_rules = optional(list(object({
      rule_number     = number
      protocol        = string
      rule_action     = string
      cidr_block      = optional(string)
      ipv6_cidr_block = optional(string)
      from_port       = number
      to_port         = number
    })), [])
  }))
  description = "Map of Public NACLs to create per subnet type"
  default     = {}
}