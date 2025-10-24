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

  # Generic subnet mapper: takes a list of CIDRs and AZs, returns a map keyed by AZ suffix
  subnet_map = {
    public  = { for idx, az in var.azs : upper(regex("([0-9]+[a-z])", az)[0]) => { az = az, cidr = var.public_subnets[idx] } }
    private = { for idx, az in var.azs : upper(regex("([0-9]+[a-z])", az)[0]) => { az = az, cidr = var.private_subnets[idx] } }
  }
}