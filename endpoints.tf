# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# VPC Endpoint
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
locals {
  flattened_vpc_endpoint_interface_services = flatten([
    for key, details in var.interface_endpoints : [
      for service_name in local.VPC_ENDPOINT_SERVICES[upper(key)] : {
        key                = format("%s-%s", key, service_name)
        service_name       = service_name
        vpc_endpoint_type  = "Interface"
        subnet_ids         = [for key in details.subnet_keys : module.subnets[local.PRIVATE].details[key].id]
        security_group_ids = [for key in details.security_group_keys : aws_security_group.this[key].id]
      }
    ]
  ])
}
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
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

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, each.key)
  })


  depends_on = [aws_security_group.this, module.subnets]
}