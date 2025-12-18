output "vpc" {
  description = "VPC details"
  value = {
    id         = aws_vpc.vpc.id
    arn        = aws_vpc.vpc.arn
    cidr_block = aws_vpc.vpc.cidr_block
    region     = aws_vpc.vpc.region
  }
}

output "active_azs" {
  description = "Map of Network Tiers(Public, Private, Database) and its active az location"
  value       = { for tier, details in local.map_subnets : tier => details.active_azs }
}

output "igw_id" {
  description = "IGW ID"
  value       = aws_internet_gateway.igw.id
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
# Dependencies : 
#   ROUTING MODULE > LOCALS_CONSTANT.TF
#   APPLICATION MODULE > LOCALS_CONSTANT.TF

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

output "subnets" {
  description = "Map of available Subnets by tier (PUB|PRV|DB)"
  value       = { for k, v in module.subnets : k => v.details }
}

output "nacls" {
  description = "Map of available Network ACLs by Tier (PUB|PRV|DB|SHARED)"
  value       = { for k, v in module.nacls : k => v.details }
}