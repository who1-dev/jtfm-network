# output "mapper" {
#   description = "Mapper of created resources"
#   value = {
#     map_public_subnets   = local.map_public_subnets
#     map_private_subnets  = local.map_private_subnets
#     map_database_subnets = local.map_database_subnets
#   }
# }

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
  value = { for az in local.sorted_azs : az => upper(regex(local.REGEX_AZ_SHORT, az)[0]) }
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


output "public_subnets" {
  description = "List of public subnet CIDRs per AZ"
  value = {
    for key, details in aws_subnet.public : key => {
      id         = details.id
      arn        = details.arn
      az         = details.availability_zone
      short_az   = upper(regex(local.REGEX_AZ_SHORT, details.availability_zone)[0])
      cidr_block = details.cidr_block
    }
  }
}

output "private_subnets" {
  description = "List of private subnet CIDRs per AZ"
  value = {
    for key, details in aws_subnet.private : key => {
      id         = details.id
      arn        = details.arn
      az         = details.availability_zone
      short_az   = upper(regex(local.REGEX_AZ_SHORT, details.availability_zone)[0])
      cidr_block = details.cidr_block
    }
  }
}

output "database_subnets" {
  description = "List of database subnet CIDRs per AZ"
  value = {
    for key, details in aws_subnet.database : key => {
      id         = details.id
      arn        = details.arn
      az         = details.availability_zone
      short_az   = upper(regex(local.REGEX_AZ_SHORT, details.availability_zone)[0])
      cidr_block = details.cidr_block
    }
  }
}

