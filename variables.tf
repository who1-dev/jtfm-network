variable "env" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Project namespace"
}

# ─────────────────────────────
# START: VPC Specific details
# ─────────────────────────────

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

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

variable "azs" {
  type        = list(string)
  description = "List of Availability zones to be used in the VPC"
}


# ─────────────────────────────
# END: VPC Specific details
# ─────────────────────────────


# ─────────────────────────────
# START: NAT Gateway related Variables
# ─────────────────────────────
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

variable "enable_nat_access_to_all_private_subnets" {
  type        = bool
  description = "This flag will create routes for Private Subnets NAT Access"
  default     = false
}

variable "enable_nat_access_to_all_database_subnets" {
  type        = bool
  description = "This flag will create routes for Database Subnets NAT Access"
  default     = false
}

variable "set_private_subnet_nat_az_connection" {
  type        = list(string)
  description = "A list of Availability Zones to connect Private Subnets to NAT Gateways. Must be a subset of var.azs."
  default     = []
  validation {
    # Check if all elements in set_nat_private_subnet_az_connection are present in var.azs
    condition = alltrue([
      for az in var.set_private_subnet_nat_az_connection : contains(var.azs, az)
    ])
    error_message = "All values in set_nat_private_subnet_az_connection must be valid Availability Zones defined in var.azs."
  }
}

variable "set_database_subnet_nat_az_connection" {
  type        = list(string)
  description = "A list of Availability Zones to connect Database Subnets to NAT Gateways. Must be a subset of var.azs."
  default     = []
  validation {
    # Check if all elements in set_nat_database_subnet_az_connection are present in var.azs
    condition = alltrue([
      for az in var.set_database_subnet_nat_az_connection : contains(var.azs, az)
    ])
    error_message = "All values in set_nat_database_subnet_az_connection must be valid Availability Zones defined in var.azs."
  }
}

# ─────────────────────────────
# END: NAT Gateway related Variables
# ─────────────────────────────



# ─────────────────────────────
# START: Subnet Variables
# ─────────────────────────────
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

# ─────────────────────────────
# END: Subnet Variables
# ─────────────────────────────

# ─────────────────────────────
# START: NACL Variables
# ─────────────────────────────
variable "public_acls" {
  type        = list(string)
  description = "List of Public Subnets to have an NACL"
  default     = []
}

variable "private_acls" {
  type        = list(string)
  description = "List of Private Subnets to have an NACL"
  default     = []
}

variable "database_acls" {
  type        = list(string)
  description = "List of Database Subnets to have an NACL"
  default     = []
}

variable "nacl_enable_public_bidirectional_rule" {
  type        = bool
  description = "Enabling this flag automaticly applies inbound rules to outbound"
  default     = true
}

variable "nacl_enable_private_bidirectional_rule" {
  type        = bool
  description = "Enabling this flag automaticly applies inbound rules to outbound"
  default     = true
}

variable "nacl_enable_database_bidirectional_rule" {
  type        = bool
  description = "Enabling this flag automaticly applies inbound rules to outbound"
  default     = true
}



variable "nacl_public_common_rules" {
  type    = list(string)
  default = []
}

variable "nacl_private_common_rules" {
  type    = list(string)
  default = []
}

variable "nacl_database_common_rules" {
  type    = list(string)
  default = []
}



variable "nacl_public_inbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Inbound NACL rules for Public Subnets NACLs with port range"
  default     = {}
}

variable "nacl_public_outbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Outbound NACL rules for Public Subnets NACLs with port range"
  default     = {}
}


variable "nacl_private_inbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Inbound NACL rules for Public Subnets NACLs with port range"
  default     = {}
}

variable "nacl_private_outbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Outbound NACL rules for Public Subnets NACLs with port range"
  default     = {}
}

variable "nacl_database_inbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Inbound NACL rules for Database Subnets NACLs with port range"
  default     = {}
}

variable "nacl_database_outbound_rules" {
  type = map(list(object({
    rule_number     = number
    egress          = bool
    protocol        = string
    rule_action     = string
    cidr_block      = optional(string)
    ipv6_cidr_block = optional(string)
    from_port       = number
    to_port         = number
  })))
  description = "Outbound NACL rules for Database Subnets NACLs with port range"
  default     = {}
}


# ─────────────────────────────
# END: NACL Variables
# ─────────────────────────────

