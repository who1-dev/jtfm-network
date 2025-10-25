# Create a route to the Internet Gateway in the Public Route Table
resource "aws_route" "public_internet_access" {
  count = local.create_public_resources ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = aws_internet_gateway.igw[0].id

  depends_on = [aws_route_table.public]
}

resource "aws_route" "private_nat_gateway_access" {
  count = local.create_private_resources && var.enable_nat_gateway && var.enable_nat_access_to_private_subnets ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = aws_nat_gateway.nat[local.az_keys[local.set_nat_az_key]].id

  depends_on = [aws_route_table.private]
}

resource "aws_route" "database_nat_gateway_access" {
  count = local.create_database_resources && var.enable_nat_gateway && var.enable_nat_access_to_database_subnets ? 1 : 0

  route_table_id         = aws_route_table.database[0].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = aws_nat_gateway.nat[local.az_keys[local.set_nat_az_key]].id

  depends_on = [aws_route_table.database]
}