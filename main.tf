# Create a VPC
resource "aws_vpc" "vpc" {
  region               = var.region
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.default_tags, {
    Name = local.namespace
  })
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.IGW)
  })

  depends_on = [aws_vpc.vpc]
}

# Create Elastic IPs for NAT Gateways (if enabled)
resource "aws_eip" "nat" {
  for_each = toset(local.list_nat_az_keys)
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.EIP, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create NAT Gateway (if enabled)
resource "aws_nat_gateway" "nat" {
  for_each      = toset(local.list_nat_az_keys)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = module.subnets.public.details[format("%s1", each.key)].id # Assuming NAT is always created at the first public subnet of the AZ

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.NATGW, each.key)
  })

  depends_on = [aws_internet_gateway.igw, module.subnets]
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# SUBNETS 
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
module "subnets" {
  source = "./sub_modules/subnets"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.vpc.id
  dict_azs     = local.dict_azs

  # Submodule-specific Variables
  for_each    = local.map_subnets
  subnet_type = each.value.type
  subnets     = each.value.subnets
}
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
