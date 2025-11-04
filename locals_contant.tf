locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

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
  PUB_NACL = "PUB-NACL"
  PRV_NACL = "PRV-NACL"
  DB_NACL  = "DB-NACL"

  NACL_COMMON_RULES = {
    inbound = {
      SSH = {
        rule_number = 100
        egress      = false
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 22
        to_port     = 22
      }        
      HTTP = {
        rule_number = 110
        egress      = false
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 80
        to_port     = 80
      }
      HTTP_IPV6 = {
        rule_number     = 111
        egress          = false
        protocol        = "tcp"
        rule_action     = "allow"
        ipv6_cidr_block = local.INTERNET_CIDR_IPV6
        from_port       = 80
        to_port         = 80
      }
      HTTPS = {
        rule_number = 120
        egress      = false
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 443
        to_port     = 443
      }
      HTTPS_IPV6 = {
        rule_number     = 121
        egress          = false
        protocol        = "tcp"
        rule_action     = "allow"
        ipv6_cidr_block = local.INTERNET_CIDR_IPV6
        from_port       = 443
        to_port         = 443
      }
    }
    outbound = {
      SSH = {
        rule_number = 100
        egress      = false
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 22
        to_port     = 22
      }   
      HTTP = {
        rule_number = 110
        egress      = true
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 80
        to_port     = 80
      }
      HTTP_IPV6 = {
        rule_number     = 111
        egress          = true
        protocol        = "tcp"
        rule_action     = "allow"
        ipv6_cidr_block = local.INTERNET_CIDR_IPV6
        from_port       = 80
        to_port         = 80
      }
      HTTPS = {
        rule_number = 120
        egress      = true
        protocol    = "tcp"
        rule_action = "allow"
        cidr_block  = local.INTERNET_CIDR
        from_port   = 443
        to_port     = 443
      }
      HTTPS_IPV6 = {
        rule_number     = 121
        egress          = true
        protocol        = "tcp"
        rule_action     = "allow"
        ipv6_cidr_block = local.INTERNET_CIDR_IPV6
        from_port       = 443
        to_port         = 443
      }
    }
  }




}