locals {

  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  NACL_COMMON_RULES = {
    SSH = {
      rule_number = 100
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = local.INTERNET_CIDR
      from_port   = 22
      to_port     = 22
    }
    HTTP = {
      rule_number = 110
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = local.INTERNET_CIDR
      from_port   = 80
      to_port     = 80
    }
    HTTP_IPV6 = {
      rule_number     = 111
      protocol        = "tcp"
      rule_action     = "allow"
      ipv6_cidr_block = local.INTERNET_CIDR_IPV6
      from_port       = 80
      to_port         = 80
    }
    HTTPS = {
      rule_number = 120
      protocol    = "tcp"
      rule_action = "allow"
      cidr_block  = local.INTERNET_CIDR
      from_port   = 443
      to_port     = 443
    }
    HTTPS_IPV6 = {
      rule_number     = 121
      protocol        = "tcp"
      rule_action     = "allow"
      ipv6_cidr_block = local.INTERNET_CIDR_IPV6
      from_port       = 443
      to_port         = 443
    }
  }
}