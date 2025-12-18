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
  description = "Dictionary of AZs specified at parent mddule: { {us-east-1a : 1A}, { 1A: us-east-1a } }	"
}

variable "subnet_type" {
  description = "Type of subnet (public, private, or database)"
  type        = string
}

variable "subnets" {
  type        = map(list(string))
  description = "Map of subnets CIDRs per AZ"
}
