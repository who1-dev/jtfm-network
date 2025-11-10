output "mapper" {
  description = "Mapper of created resources"
  value = {
    map_public_subnets   = local.map_public_subnets
    map_private_subnets  = local.map_private_subnets
    map_database_subnets = local.map_database_subnets
  }
}

output "vpc" {
  description = "VPC Details"
  value = aws_vpc.vpc
}

output "igw_id" {
  description = "IGW ID"
  value = aws_internet_gateway.igw.id
}

output "nat_gateways" {
  description = "NAT Gateways"
  value = aws_nat_gateway.nat
}

output "public_subnets" {
  description = "List of public subnet CIDRs per AZ"
  value = aws_subnet.public
}

output "private_subnets" {
  description = "List of private subnet CIDRs per AZ"
  value = aws_subnet.private
}

output "database_subnets" {
  description = "List of database subnet CIDRs per AZ"
  value = aws_subnet.database
}