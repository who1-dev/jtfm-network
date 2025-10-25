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
  count = local.create_public_resources ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.IGW)
  })

  depends_on = [aws_vpc.vpc]
}

# Create NAT Gateway (if enabled)
resource "aws_eip" "nat" {
  for_each = toset(local.nat_gw_map) # Allocate an Elastic IP for each NAT Gateway

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.EIP, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}


resource "aws_nat_gateway" "nat" {
  for_each      = toset(local.nat_gw_map)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.NATGW, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = local.subnet_map.public

  vpc_id            = aws_vpc.vpc.id
  region            = var.region
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PUB_SUB, each.key)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = local.subnet_map.private

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
  for_each = local.subnet_map.database

  vpc_id            = aws_vpc.vpc.id
  region            = var.region
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_SUB, each.key)
  })

  depends_on = [aws_vpc.vpc]
}

# Create a Public Route Table
resource "aws_route_table" "public" {
  count = local.create_public_resources ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_RT)
  })

  depends_on = [aws_internet_gateway.igw]
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  count = local.create_private_resources ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PRV_RT)
  })

  depends_on = [aws_vpc.vpc]
}

# Create a Database Route Table
resource "aws_route_table" "database" {
  count = local.create_database_resources ? 1 : 0

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.DB_RT)
  })

  depends_on = [aws_vpc.vpc]
}


# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id

  depends_on = [aws_route_table.public]
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id

  depends_on = [aws_route_table.private]
}


# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "database" {
  for_each       = aws_subnet.database
  subnet_id      = each.value.id
  route_table_id = aws_route_table.database[0].id

  depends_on = [aws_route_table.database]
}


