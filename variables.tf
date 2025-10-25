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

variable "set_nat_az_location" {
  type        = string
  description = "Set AZ where the NAT Gateway should be placed"
  default     = ""
}

variable "enable_nat_access_to_private_subnets" {
  type        = bool
  description = "This flag will create route for Private Subnets NAT Access"
  default     = false
}

variable "enable_nat_access_to_database_subnets" {
  type        = bool
  description = "This flag will create route for Database Subnets NAT Access"
  default     = false
}
# ─────────────────────────────
# END: NAT Gateway related Variables
# ─────────────────────────────


# ─────────────────────────────
# START: Subnet Variables
# ─────────────────────────────
variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default     = []
  validation {
    condition     = !(length(var.public_subnets) > 0 && length(var.public_subnets) != length(var.azs))
    error_message = "ERROR: The number of availability zones must match the number of public subnets declared"
  }
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
  default     = []
  validation {
    condition     = !(length(var.private_subnets) > 0 && length(var.private_subnets) != length(var.azs))
    error_message = "ERROR: The number of availability zones must match the number of private subnets declared"
  }
}

variable "database_subnets" {
  type        = list(string)
  description = "List of database subnet CIDR blocks"
  default     = []
  validation {
    condition     = !(length(var.database_subnets) > 0 && length(var.database_subnets) != length(var.azs))
    error_message = "ERROR: The number of availability zones must match the number of database subnets"
  }
}

# ─────────────────────────────
# END: Subnet Variables
# ─────────────────────────────


