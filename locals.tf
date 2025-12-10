locals {
  # Local name
  namespace = upper(format("%s-%s", var.namespace, var.env))

  # Sorted AZs
  sorted_azs = sort(var.azs)

  # Generic Dictionaries
  dict_azs = merge(
    { for az in local.sorted_azs : az => upper(regex(local.REGEX_AZ_SHORT, az)[0]) },
    { for az in local.sorted_azs : upper(regex(local.REGEX_AZ_SHORT, az)[0]) => az }
  )


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # SUBNET Related Locals
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
  # ROUTE TABLE Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  list_public_az_keys = [for az, cidrs in var.public_subnets : local.dict_azs[az] if contains(keys(local.dict_azs), az) && length(cidrs) > 0]


  # NAT Gateway related AZ keys | NOTE: NAT will always be deployed in First Public Subnet of each AZs only
  list_nat_az_keys = !var.enable_nat_gateway ? [] : var.deploy_nat_in_all_public_azs ? local.list_public_az_keys : length(var.set_nat_deployment_az_location) == 0 ? [local.list_public_az_keys[0]] : [
    for az in var.set_nat_deployment_az_location : local.dict_azs[az]
    if contains(local.list_public_az_keys, local.dict_azs[az])
  ]

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # Security Group Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  flattened_security_group_ingress_rules = flatten([
    for key, details in var.security_groups : [
      for idx, rule in details.rules : {
        key                           = key
        ing_key                       = format("%s-%d", key, idx + 1)
        referenced_security_group_key = lookup(rule, "referenced_security_group_key", null)
        ip_protocol                   = lookup(rule, "ip_protocol", "tcp")
        port                          = rule.port
        cidr_block                    = rule.cidr_block
        description                   = lookup(rule, "description", null)
      }
    ]
  ])


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # VPC Endpoint Related Locals
  # ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  flattened_vpc_endpoint_interface_services = flatten([
    for key, details in var.interface_endpoints : [
      for service_name in local.VPC_ENDPOINT_SERVICES[upper(key)] : {
        key                = format("%s-%s", key, service_name)
        service_name       = service_name
        vpc_endpoint_type  = "Interface"
        subnet_ids         = [for key in details.subnet_keys : aws_subnet.private[key].id]
        security_group_ids = [for key in details.security_group_keys : aws_security_group.this[key].id]
      }
    ]
  ])


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # NACL Related Locals
  #   # By default: nacl_enable_public_bidirectional_rule is set to true
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

  # PUBLIC NACL Rules ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  flattened_public_inbound_acl_rules = flatten([
    for acl_key, rules in {
      for key, rule_set in var.nacl_public_inbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_public_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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
    for acl_key, rules in {
      for key, rule_set in var.nacl_public_outbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_public_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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


  # PRIVATE NACL Rules ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  flattened_private_inbound_acl_rules = flatten([
    for acl_key, rules in {
      for key, rule_set in var.nacl_private_inbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_private_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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
    for acl_key, rules in {
      for key, rule_set in var.nacl_private_outbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_private_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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

  # DATABASE NACL Rules ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  flattened_database_inbound_acl_rules = flatten([
    for acl_key, rules in {
      for key, rule_set in var.nacl_database_inbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_database_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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
    for acl_key, rules in {
      for key, rule_set in var.nacl_database_outbound_rules : key => concat(
        rule_set,
        [for protocol in var.nacl_database_common_rules : local.NACL_COMMON_RULES[protocol]]
      )
      } : [
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