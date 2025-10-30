locals {

  # Constants:
  INTERNET_CIDR  = "0.0.0.0/0"
  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "Environment" : upper(var.env) }

  # Constant Naming conventions:
  VPC      = "VPC"
  IGW      = "IGW"
  NATGW    = "NATGW"
  EIP      = "EIP"
  PRV_SUB  = "PRVSUB"
  PUB_SUB  = "PUBSUB"
  DB_SUB   = "DBSUB"
  PRV_RT   = "PRVRT"
  PUB_RT   = "PUBRT"
  DB_RT    = "DBRT"
  RT_ASSOC = "RTASSOC"

  # Local name
  namespace = upper(format("%s-%s-%s", var.namespace, var.env, local.VPC))


  # Sorted AZs
  sorted_azs = sort(var.azs)


  # Lengths:
  len_azs              = length(var.azs)
  len_pub_sub          = length(var.public_subnets)
  len_prv_sub          = length(var.private_subnets)
  len_db_sub           = length(var.database_subnets)
  len_nat_az_locations = var.enable_nat_gateway ? length(var.set_nat_deployment_az_location) : 0


  # Booleans:
  create_public_resources   = local.len_pub_sub > 0 ? true : false
  create_private_resources  = local.len_prv_sub > 0 ? true : false
  create_database_resources = local.len_db_sub > 0 ? true : false


  # Lists
  list_az_keys     = [for az in local.sorted_azs : upper(regex(local.REGEX_AZ_SHORT, az)[0])]
  list_nat_az_keys = [for az in sort(var.set_nat_deployment_az_location) : upper(regex(local.REGEX_AZ_SHORT, az)[0])]

  # Sliced Lists: wil be used as keys for route tables
  list_private_az_keys  = slice(local.list_az_keys, 0, (local.len_prv_sub < local.len_azs ? local.len_prv_sub : local.len_azs))
  list_database_az_keys = slice(local.list_az_keys, 0, (local.len_db_sub < local.len_azs ? local.len_db_sub : local.len_azs))

  # Subnet per AZ calculations:
  len_pub_sub_per_az = local.create_public_resources ? local.len_pub_sub / local.len_azs : 0
  len_prv_sub_per_az = local.create_private_resources ? local.len_prv_sub / local.len_azs : 0
  len_db_sub_per_az  = local.create_database_resources ? local.len_db_sub / local.len_azs : 0


  # Generate subnet keys: e.g., 1A1, 1A2, 1B1, 1B2 for 2 AZs and 4 subnets
  keys_pub_sub = {
    for idx, cidr in var.public_subnets :
    "${local.list_az_keys[idx % local.len_azs]}${floor(idx / local.len_azs) + 1}" => {
      az       = local.sorted_azs[idx % local.len_azs]
      short_az = local.list_az_keys[idx % local.len_azs]
      cidr     = cidr
    }
  }
  keys_prv_sub = {
    for idx, cidr in var.private_subnets :
    "${local.list_az_keys[idx % local.len_azs]}${floor(idx / local.len_azs) + 1}" => {
      az       = local.sorted_azs[idx % local.len_azs]
      short_az = local.list_az_keys[idx % local.len_azs]
      cidr     = cidr
    }
  }
  keys_db_sub = {
    for idx, cidr in var.database_subnets :
    "${local.list_az_keys[idx % local.len_azs]}${floor(idx / local.len_azs) + 1}" => {
      az       = local.sorted_azs[idx % local.len_azs]
      short_az = local.list_az_keys[idx % local.len_azs]
      cidr     = cidr
    }
  }

}