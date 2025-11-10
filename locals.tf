locals {
  # Local name
  namespace = upper(format("%s-%s-%s", var.namespace, var.env, local.VPC))


  # Sorted AZs
  sorted_azs = sort(var.azs)

  # Generic Dictionaries
  dict_azs = merge(
    { for az in local.sorted_azs : az => upper(regex(local.REGEX_AZ_SHORT, az)[0]) },
    { for az in local.sorted_azs : upper(regex(local.REGEX_AZ_SHORT, az)[0]) => az }
  )

  # Generic Lists
  list_az_keys = [for az in local.sorted_azs : local.dict_azs[az]]


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: SUBNET Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # Generate subnet keys: e.g., 1A1, 1A2, 1B1, 1B2 for 2 AZs and 4 subnets | 3 AZs and 5 subnets : 1A1, 1B1, 1C1, 2A1, 2B1
  map_public_subnets = merge([
    for az, cidrs in var.public_subnets : {
      for idx, cidr in cidrs :
      format("%s%d", local.dict_azs[az], idx + 1) => { az = az, cidr = cidr, short_az = local.dict_azs[az] }
    }
  ]...)

  map_private_subnets = merge([
    for az, cidrs in var.private_subnets : {
      for idx, cidr in cidrs :
      format("%s%d", local.dict_azs[az], idx + 1) => { az = az, cidr = cidr, short_az = local.dict_azs[az] }
    }
  ]...)

  map_database_subnets = merge([
    for az, cidrs in var.database_subnets : {
      for idx, cidr in cidrs :
      format("%s%d", local.dict_azs[az], idx + 1) => { az = az, cidr = cidr, short_az = local.dict_azs[az] }
    }
  ]...)

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # END: SUBNET Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: ROUTE TABLE Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  list_public_az_keys   = [for az, cidrs in var.public_subnets : local.dict_azs[az] if contains(keys(local.dict_azs), az) && length(cidrs) > 0]
  list_private_az_keys  = [for az, cidrs in var.private_subnets : local.dict_azs[az] if contains(keys(local.dict_azs), az) && length(cidrs) > 0]
  list_database_az_keys = [for az, cidrs in var.database_subnets : local.dict_azs[az] if contains(keys(local.dict_azs), az) && length(cidrs) > 0]


  # NAT Gateway related AZ keys | NOTE: NAT will always be deployed in First Public Subnet of each AZs only
  list_nat_az_keys = !var.enable_nat_gateway ? [] : length(var.set_nat_deployment_az_location) == 0 ? [local.list_public_az_keys[0]] : (var.deploy_nat_in_all_public_azs ?
    local.list_public_az_keys : [for az in var.set_nat_deployment_az_location : local.dict_azs[az]
    if contains(local.list_public_az_keys, local.dict_azs[az])]
  )

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # START: END TABLE Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


  # Merge common rules into each ACL entry
  nacl_public_inbound_rules = length(var.nacl_public_inbound_rules) == 0 ? var.nacl_public_inbound_rules : {
    for key, rules in var.nacl_public_inbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_public_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }

  nacl_public_outbound_rules = length(var.nacl_public_outbound_rules) == 0 ? var.nacl_public_outbound_rules : {
    for key, rules in var.nacl_public_outbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_public_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }

  # PRIVATE NACL - INBOUND
  nacl_private_inbound_rules = length(var.nacl_private_inbound_rules) == 0 ? var.nacl_private_inbound_rules : {
    for key, rules in var.nacl_private_inbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_private_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }

  # PRIVATE NACL - OUTBOUND
  nacl_private_outbound_rules = length(var.nacl_private_outbound_rules) == 0 ? var.nacl_private_outbound_rules : {
    for key, rules in var.nacl_private_outbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_private_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }


  # DATABASE NACL - INBOUND
  nacl_database_inbound_rules = length(var.nacl_database_inbound_rules) == 0 ? var.nacl_database_inbound_rules : {
    for key, rules in var.nacl_database_inbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_database_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }

  # DATABASE NACL - OUTBOUND
  nacl_database_outbound_rules = length(var.nacl_database_outbound_rules) == 0 ? var.nacl_database_outbound_rules : {
    for key, rules in var.nacl_database_outbound_rules : key => concat(
      rules,
      [
        for protocol in var.nacl_database_common_rules : local.NACL_COMMON_RULES[protocol]
      ]
    )
  }





  flattened_public_inbound_acl_rules = flatten([
    for acl_key, rules in local.nacl_public_inbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])

  flattened_public_outbound_acl_rules = var.nacl_enable_public_bidirectional_rule ? local.flattened_public_inbound_acl_rules : flatten([
    for acl_key, rules in local.nacl_public_outbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])


  flattened_private_inbound_acl_rules = flatten([
    for acl_key, rules in local.nacl_private_inbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])

  flattened_private_outbound_acl_rules = var.nacl_enable_private_bidirectional_rule ? local.flattened_private_inbound_acl_rules : flatten([
    for acl_key, rules in local.nacl_private_outbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])


  flattened_database_inbound_acl_rules = flatten([
    for acl_key, rules in local.nacl_database_inbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])

  flattened_database_outbound_acl_rules = var.nacl_enable_database_bidirectional_rule ? local.flattened_database_inbound_acl_rules : flatten([
    for acl_key, rules in local.nacl_database_outbound_rules : [
      for rule in rules : {
        acl_key         = acl_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = lookup(rule, "cidr_block", null)
        ipv6_cidr_block = lookup(rule, "ipv6_cidr_block", null)
        from_port       = rule.from_port
        to_port         = rule.to_port
      }
    ]
  ])



}