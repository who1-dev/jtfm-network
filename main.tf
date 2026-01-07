# Create a VPC
resource "aws_vpc" "this" {
  region               = var.region
  cidr_block           = var.cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.VPC)
  })
}

# Create VPC Flow Logs (if enabled)
resource "aws_flow_log" "this" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  iam_role_arn    = data.aws_iam_role.vpc_flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(
    var.default_tags,
    {
      Name = lower("${var.namespace}-${var.env}-${local.flow_log}")
    }
  )
}

# Create CloudWatch Log Group for VPC Flow Logs (if enabled)
resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  name              = lower("/aws/${local.flow_log}/${var.namespace}-${var.env}")
  retention_in_days = var.flow_log_retention
}



# Create an Internet Gateway
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id
  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.IGW)
  })

  depends_on = [aws_vpc.this]
}

# Create Elastic IPs for NAT Gateways (if enabled)
resource "aws_eip" "nat" {
  for_each = toset(local.list_nat_az_keys)
  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.EIP, each.key)
  })

  depends_on = [aws_internet_gateway.this]
}

# Create NAT Gateway (if enabled)
resource "aws_nat_gateway" "nat" {
  for_each      = toset(local.list_nat_az_keys)
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = module.subnets.public.details[format("%s1", each.key)].id # Assuming NAT is always created at the first public subnet of the AZ

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s", local.namespace, local.NATGW, each.key)
  })

  depends_on = [aws_internet_gateway.this, module.subnets]
}

# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# SUBNETS 
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
module "subnets" {
  source = "./modules/subnets"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.this.id
  dict_azs     = local.dict_azs

  # Submodule-specific Variables
  for_each    = local.map_subnets
  subnet_type = each.value.type
  subnets     = each.value.subnets
}
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
