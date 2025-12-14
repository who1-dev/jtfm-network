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
  # NAT Gateway Related Locals
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
        subnet_ids         = [for key in details.subnet_keys : module.private_subnets[key].id]
        security_group_ids = [for key in details.security_group_keys : aws_security_group.this[key].id]
      }
    ]
  ])

}