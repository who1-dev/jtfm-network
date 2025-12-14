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

variable "dict_azs" {
  type        = any
  description = "List of availability zones to use"
}

variable "subnet_type" {
  description = "Type of subnet (public, private, or database)"
  type        = string
}

variable "subnets" {
  type        = map(list(string))
  description = "List of subnets CIDRs per AZ"
}
