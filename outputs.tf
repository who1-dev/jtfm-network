output "vpc" {
  description = "VPC details"
  value = {
    id         = aws_vpc.vpc.id
    arn        = aws_vpc.vpc.arn
    cidr_block = aws_vpc.vpc.cidr_block
    region     = aws_vpc.vpc.region
  }
}


output "igw_id" {
  description = "IGW ID"
  value       = aws_internet_gateway.igw.id
}

output "azs" {
  description = "List of Availability Zones"
  value       = { for az in local.sorted_azs : az => upper(regex(local.REGEX_AZ_SHORT, az)[0]) }
}

output "nat_gateways" {
  description = "NAT Gateways"
  value = {
    for key, details in aws_nat_gateway.nat : key => {
      id                   = details.id
      region               = details.region
      network_interface_id = details.network_interface_id
      subnet_id            = details.subnet_id
    }
  }
}


# WARNING!!! Changing the outputs name below will require changes in the dependent module
# Dependencies : [APPLICATION MODULE > LOCALS_CONSTANT.TF]
output "security_groups" {
  description = "List of available Security Groups"
  value = {
    for key, details in aws_security_group.this : key => {
      id          = details.id
      arn         = details.arn
      name        = details.name
      description = details.description
    }
  }
}

output "active_azs" {
  description = "List of Network Tiers(Public, Private, Database) and its active az location"
  value       = { for tier, details in local.map_subnets : tier => details.active_azs }
}

output "public_subnets" {
  description = "List of available public subnets"
  value       = try(module.subnets[local.PUBLIC].details, {})
}

output "private_subnets" {
  description = "List of available private subnets"
  value       = try(module.subnets[local.PRIVATE].details, {})
}

output "database_subnets" {
  description = "List of available database subnets"
  value       = try(module.subnets[local.DATABASE].details, {})
}

output "nacls" {
  description = "List of available Network ACLs"
  value       = { for k, v in module.nacls : k => v.details }
}