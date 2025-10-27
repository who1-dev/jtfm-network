locals {

  # Constants:
  INTERNET_CIDR = "0.0.0.0/0"
  default_tags  = { "Environment" : upper(var.env) }

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

  # Mappers:
  # Generic subnet mapper: takes a list of CIDRs and AZs, returns a map keyed by AZ suffix
  # Regex will render '1a' from 'us-east-1a' and convert to uppercase '1A' e.g., 'us-east-1a' -> '1A'
  az_keys = { for az in var.azs : az => upper(regex("([0-9]+[a-z])", az)[0]) }

  subnet_map = {
    # Subnet maps for public, private, and database subnets each keyed by AZ suffix e.g., 1A, 1B
    public   = local.create_public_resources ? { for idx, az in var.azs : local.az_keys[az] => { az = az, cidr = var.public_subnets[idx] } } : {}
    private  = local.create_private_resources ? { for idx, az in var.azs : local.az_keys[az] => { az = az, cidr = var.private_subnets[idx] } } : {}
    database = local.create_database_resources ? { for idx, az in var.azs : local.az_keys[az] => { az = az, cidr = var.database_subnets[idx] } } : {}
  }

  natgw_map = !var.enable_nat_gateway ? {} : (
    # If NAT is enabled, check this:
    (length(var.set_nat_az_location) == 0) ?                                             # Is the set_nat_az_location list empty?
    { 0 : { location : local.az_keys[var.azs[0]] } } :                                   # YES: create a map using the first AZ
    { for idx, az in var.set_nat_az_location : idx => { location : local.az_keys[az] } } # NO: create a map from the list
  )


  # Counters:
  len_pub_sub =  length(var.public_subnets) 
  len_prv_sub = length(var.private_subnets)
  len_db_sub  = length(var.database_subnets)



  # Conditional Logic:
  # Flags 
  # Determine which resources to create based on input variables
  create_public_resources   = local.len_pub_sub > 0 ? true : false
  create_private_resources  = local.len_prv_sub > 0 ? true : false
  create_database_resources = local.len_db_sub > 0 ? true : false
  is_nat_multiaz_enabled    = var.enable_nat_gateway && length(var.set_nat_az_location) > 1 ? true : false


  # Counters for Route Tables
  len_prv_rt = !local.create_private_resources ? 0 : local.is_nat_multiaz_enabled ? local.len_prv_sub : 1
  len_db_rt  = !local.create_database_resources ? 0 : local.is_nat_multiaz_enabled ? local.len_db_sub : 1



}