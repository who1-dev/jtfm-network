# Create a route to the Internet Gateway in the Public Route Table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = local.INTERNET_CIDR
  gateway_id             = aws_internet_gateway.igw.id
}