locals {

  # Constants:
  INTERNET_CIDR = "0.0.0.0/0"
  default_tags  = { "Environment" : upper(var.env) }

  # Naming conventions:
  VPC      = "VPC"
  IGW      = "IGW"
  PRV_SUB  = "PRVSUB"
  PUB_SUB  = "PUBSUB"
  PRV_RT   = "PRVRT"
  PUB_RT   = "PUBRT"
  RT_ASSOC = "RTASSOC"

  # Local name
  namespace = upper(format("%s-%s-%s", var.namespace, var.env, local.VPC))


  # Conditions:
  # Determine whether to create public/private resources based on subnet inputs
  create_public_resources  = length(var.public_subnets) > 0 ? true : false
  create_private_resources = length(var.private_subnets) > 0 ? true : false


  # Mappers:
  # Generic subnet mapper: takes a list of CIDRs and AZs, returns a map keyed by AZ suffix
  subnet_map = {
    # Regex will render '1a' from 'us-east-1a' and convert to uppercase '1A'
    public  = local.create_public_resources ? { for idx, az in var.azs : upper(regex("([0-9]+[a-z])", az)[0]) => { az = az, cidr = var.public_subnets[idx] } } : {}
    private = local.create_private_resources ? { for idx, az in var.azs : upper(regex("([0-9]+[a-z])", az)[0]) => { az = az, cidr = var.private_subnets[idx] } } : {}
  }
}