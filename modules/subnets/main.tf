locals {

  # Should be Identical to the parent module. Else `map_public_ip_on_launch` will always be false
  PUBLIC = "PUBLIC"

  # Generate subnet keys: e.g., 1A1, 1A2, 1B1, 1B2 for 2 AZs and 4 subnets | 3 AZs and 5 subnets : 1A1, 1B1, 1C1, 2A1, 2B1
  map_subnets = merge([
    for az, cidrs in var.subnets : {
      for idx, cidr in cidrs :
      format("%s%d", var.dict_azs[az], idx + 1) => { az = az, cidr = cidr, short_az = var.dict_azs[az] }
    }
  ]...)

}

# Create Public | Private | Database Subnets
resource "aws_subnet" "this" {
  for_each = local.map_subnets

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.default_tags, {
    Name = format("%s-%s-%s", var.namespace, upper(var.subnet_type), each.key)
  })
}