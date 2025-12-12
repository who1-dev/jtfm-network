#Create a VPC Endpoint for specified Interface Services
resource "aws_vpc_endpoint" "interface" {
  for_each = {
    for details in local.flattened_vpc_endpoint_interface_services : details.key => details
  }
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.${each.value.service_name}"
  vpc_endpoint_type   = each.value.vpc_endpoint_type
  subnet_ids          = each.value.subnet_ids
  security_group_ids  = each.value.security_group_ids
  private_dns_enabled = true
  depends_on          = [aws_subnet.private, aws_security_group.this]
}