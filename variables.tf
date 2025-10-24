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

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default     = []
  validation {
    condition     = !(length(var.public_subnets) > 0 && length(var.public_subnets) != length(var.azs))
    error_message = "ERROR: The number of public subnets must match the number of availability zones."
  }
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDR blocks"
  default     = []
  validation {
    condition     = !(length(var.private_subnets) > 0 && length(var.private_subnets) != length(var.azs))
    error_message = "ERROR: The number of private subnets must match the number of availability zones."
  }
}