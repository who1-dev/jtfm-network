# Create a VPC
resource "aws_vpc" "vpc" {
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
}

# Create Public Subnets
resource "aws_subnet" "public" {
  for_each = local.subnet_map.public

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PUB_SUB, each.key)
  })
}

# Create Private Subnets
resource "aws_subnet" "private" {
  for_each = local.subnet_map.private

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PRV_SUB, each.key)
  })
}

# Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_RT)
  })
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PRV_RT)
  })
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}


