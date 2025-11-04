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
  for_each = local.keys_pub_sub

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
  for_each = local.keys_prv_sub

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
  for_each = local.keys_db_sub

  vpc_id            = aws_vpc.vpc.id
  region            = var.region
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_SUB, each.key)
  })

  depends_on = [aws_vpc.vpc]
}

# # Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_RT)
  })

  depends_on = [aws_subnet.public]
}

# Create a Private Route Table
resource "aws_route_table" "private" {
  for_each = toset(local.list_private_az_keys)

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.PRV_RT, each.key)
  })

  depends_on = [aws_subnet.private]
}

# Create a Database Route Table
resource "aws_route_table" "database" {
  for_each = toset(local.list_database_az_keys)

  vpc_id = aws_vpc.vpc.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.DB_RT, each.key)
  })

  depends_on = [aws_subnet.database]
}


# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  for_each       = local.keys_pub_sub
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_route_table.public]
}

# # Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  for_each = local.keys_prv_sub

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.short_az].id

  depends_on = [aws_route_table.private]
}

# Associate Database Subnets with Private Route Table
resource "aws_route_table_association" "database" {
  for_each = local.keys_db_sub

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.value.short_az].id

  depends_on = [aws_route_table.database]
}

# Create Public Network ACL
resource "aws_network_acl" "public" {
  for_each = toset(var.public_acls)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_NACL)
  })

  depends_on = [aws_subnet.public]

}

resource "aws_network_acl_association" "public" {
  for_each = toset(var.public_acls)
  network_acl_id = aws_network_acl.public[each.key].id
  subnet_id      = aws_subnet.public[each.key].id

  depends_on = [ aws_network_acl.public ]
}


resource "aws_network_acl_rule" "public_acl" {
  for_each = {
    for idx, rule in local.flattened_inbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.public[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = each.value.egress
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [ aws_network_acl_association.public ]
}


