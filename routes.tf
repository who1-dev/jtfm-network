#Create a route to the Internet Gateway in the Public Route Table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = aws_internet_gateway.igw.id

  depends_on = [aws_route_table.public]
}

resource "aws_route" "private_nat_gateway_access" {
  for_each = toset(local.list_private_az_keys_with_nat_access)

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id

  depends_on = [aws_route_table.private]
}

resource "aws_route" "database_nat_gateway_access" {
  for_each = toset(local.list_database_az_keys_with_nat_access)

  route_table_id         = aws_route_table.database[each.key].id
  destination_cidr_block = local.INTERNET_CIDR
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id

  depends_on = [aws_route_table.database]
}


