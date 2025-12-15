variable "env" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Project namespace"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

# START: VPC Specific details ─────────────────────────────
variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type        = string
  description = "Instance tenancy for the VPC"
  default     = "default"
}
variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}
variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "azs" {
  type        = list(string)
  description = "List of Availability zones to be used in the VPC"
}
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────







# START: NAT Gateway related Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────────────-
variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnets"
  default     = false
  validation {
    condition     = !var.enable_nat_gateway || length(var.public_subnets) > 0
    error_message = "ERROR: NAT Gateway requires public subnet to be provisioned."
  }
}

variable "deploy_nat_in_all_public_azs" {
  type        = bool
  description = "Deploy NAT Gateways in all public subnet AZs if true, else use set_nat_deployment_az_location"
  default     = true
}

variable "set_nat_deployment_az_location" {
  type        = list(string)
  description = "A list of Availability Zones to deploy NAT Gateways in. Must be a subset of var.azs."
  default     = []
  validation {
    # Check if all elements in set_nat_az_location are present in var.azs
    condition = alltrue([
      for az in var.set_nat_deployment_az_location : contains(var.azs, az)
    ])
    error_message = "All values in set_nat_az_location must be valid Availability Zones defined in var.azs."
  }
}
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# START: VPC endpoint related Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────────────-
variable "interface_endpoints" {
  type = map(object({
    subnet_keys         = list(string)
    security_group_keys = list(string)
  }))
  description = "Map of Interface VPC Endpoints"
  default     = {}
}
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────




# START: Subnet Variables ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

variable "public_subnets" {
  type        = map(list(string))
  description = "List of public subnet CIDRs per AZ"
  default     = {}
  validation {
    condition = alltrue([
      for az, cidrs in var.public_subnets : contains(var.azs, az)
    ])
    error_message = "Specified AZ keys should exists on var.azs"
  }
}


variable "private_subnets" {
  type        = map(list(string))
  description = "List of private subnet CIDRs per AZ"
  default     = {}
  validation {
    condition = alltrue([
      for az, cidrs in var.private_subnets : contains(var.azs, az)
    ])
    error_message = "Specified AZ keys should exists on var.azs"
  }
}

variable "database_subnets" {
  type        = map(list(string))
  description = "List of database subnet CIDRs per AZ"
  default     = {}
  validation {
    condition = alltrue([
      for az, cidrs in var.database_subnets : contains(var.azs, az)
    ])
    error_message = "Specified AZ keys should exists on var.azs"
  }
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


# START: Security Group related Variables ──────────────────────────────────────────────────────────────────────────────────────────────────────────────-
variable "security_groups" {
  type = map(object({
    name        = string
    description = string
    rules = list(object({
      port                          = number
      cidr_block                    = optional(string)
      referenced_security_group_key = optional(string, null)
      ip_protocol                   = optional(string, "tcp")
    }))
  }))
  description = "Map of security groups"
  default     = {}
}
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

# START: NACL Variables ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
variable "nacls_shared" {
  type = map(object({
    name             = optional(string)
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


variable "nacls_public" {
  type = map(object({
    name             = optional(string)
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

variable "nacls_private" {
  type = map(object({
    name             = optional(string)
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
  description = "Map of Private NACLs to create per subnet type"
  default     = {}

}

variable "nacls_database" {
  type = map(object({
    name             = optional(string)
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
  description = "Map of Database NACLs to create per subnet type"
  default     = {}

}


# ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────




