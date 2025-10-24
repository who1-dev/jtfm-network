# Create a route to the Internet Gateway in the Public Route Table
resource "aws_route" "public_internet_access" {
  count = local.create_public_resources ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = aws_internet_gateway.igw[0].id
}