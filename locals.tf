locals {

  # Constants:
  INTERNET_CIDR = "0.0.0.0/0"
  default_tags  = { "Environment" : upper(var.env) }

  # Naming conventions:
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


  # Conditions:
  # Flags to determine if resources should be created based on input variables
  # Determine which resources to create based on input variables
  create_public_resources   = length(var.public_subnets) > 0 ? true : false
  create_private_resources  = length(var.private_subnets) > 0 ? true : false
  create_database_resources = length(var.database_subnets) > 0 ? true : false


  # Determine the AZ key to be used for NAT Gateway
  set_nat_az_key = (
    var.set_nat_az_location != "" && contains(var.azs, var.set_nat_az_location) # if set and valid
  ) ? var.set_nat_az_location : var.azs[0]                                      # Default to first AZ if not set or invalid

  # Create NAT Gateway map only if enabled
  nat_gw_map = var.enable_nat_gateway ? [local.az_keys[local.set_nat_az_key]] : []

}