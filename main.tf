# Create a VPC
resource "aws_vpc" "vpc" {
  region           = var.region
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy

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
  subnet_id     = aws_subnet.public[format("%s1", each.key)].id # Assuming NAT is created in the first public subnet of the AZ

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.NATGW, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = local.map_public_subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PUB_SUB, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = local.map_private_subnets

  vpc_id            = aws_vpc.vpc.id
  region            = var.region
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PRV_SUB, each.key)
  })

  depends_on = [aws_vpc.vpc]
}

# Create Database Subnets
resource "aws_subnet" "database" {
  for_each = local.map_database_subnets

  vpc_id            = aws_vpc.vpc.id
  region            = var.region
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_SUB, each.key)
  })

  depends_on = [aws_vpc.vpc]
}



