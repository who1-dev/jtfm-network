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
  len_azs     = length(var.azs)
  len_pub_sub = length(var.public_subnets)
  len_prv_sub = length(var.private_subnets)
  len_db_sub  = length(var.database_subnets)

  # Booleans:
  create_public_resources   = local.len_pub_sub > 0 ? true : false
  create_private_resources  = local.len_prv_sub > 0 ? true : false
  create_database_resources = local.len_db_sub > 0 ? true : false


  # Dictionaries
  dict_azs = { for az in local.sorted_azs : az => upper(regex(local.REGEX_AZ_SHORT, az)[0]) }


  # Lists
  list_az_keys = [for az in local.sorted_azs : local.dict_azs[az]]





  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: SUBNET Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # Generate subnet keys: e.g., 1A1, 1A2, 1B1, 1B2 for 2 AZs and 4 subnets | 3 AZs and 5 subnets : 1A1, 1B1, 1C1, 2A1, 2B1
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

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # END: SUBNET Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  
  
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: ROUTE (TABLE || ASSOCIATION) Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # ROUTE TABLE RELATED LOCALS
  # Sliced Lists: wil be used as keys for route tables
  list_public_az_keys   = slice(local.list_az_keys, 0, (local.len_pub_sub < local.len_azs ? local.len_pub_sub : local.len_azs))
  list_private_az_keys  = slice(local.list_az_keys, 0, (local.len_prv_sub < local.len_azs ? local.len_prv_sub : local.len_azs))
  list_database_az_keys = slice(local.list_az_keys, 0, (local.len_db_sub < local.len_azs ? local.len_db_sub : local.len_azs))

  # NAT Gateway related AZ keys | NOTE: NAT will always be deployed in First Public Subnet of each AZs only
  list_nat_az_keys = !var.enable_nat_gateway ? [] : (var.deploy_nat_in_all_public_azs ?
    local.list_public_az_keys : [for az in var.set_nat_deployment_az_location : local.dict_azs[az]
    if contains(local.list_public_az_keys, local.dict_azs[az])]
  )



  # ROUTE TABLE ASSOCIATIONS RELATED LOCALS
  # Valid NAT connections for Private and Database Subnets
  valid_private_nat_az_connections = !var.enable_nat_gateway || local.list_nat_az_keys == 0  ? [] : [for az in local.list_private_az_keys : az
    if contains(local.list_nat_az_keys, az)
  ]

  valid_database_nat_az_connections = !var.enable_nat_gateway || local.list_nat_az_keys == 0  ? [] : [for az in local.list_database_az_keys : az
    if contains(local.list_nat_az_keys, az)
  ]


  # Route Table Associations related lists
  list_private_az_keys_with_nat_access = (
    var.enable_nat_gateway && var.enable_nat_access_to_all_private_subnets
    ) ? local.valid_private_nat_az_connections : [
    for az in var.set_private_subnet_nat_az_connection : local.dict_azs[az]
    if contains(local.valid_private_nat_az_connections, local.dict_azs[az])
  ]

  list_database_az_keys_with_nat_access = (
    var.enable_nat_gateway && var.enable_nat_access_to_all_database_subnets
    ) ? local.valid_database_nat_az_connections : [
    for az in var.set_database_subnet_nat_az_connection : local.dict_azs[az]
    if contains(local.valid_database_nat_az_connections, local.dict_azs[az])
  ]

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: END TABLE Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────






}