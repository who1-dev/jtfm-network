locals {
  # Local name
  namespace = lower(format("%s-%s", var.namespace, var.env))

  # Sorted AZs
  sorted_azs = sort(var.azs)

  # Generic Dictionaries
  dict_azs = merge(
    { for az in local.sorted_azs : az => regex(local.REGEX_AZ_SHORT, az)[0] },
    { for az in local.sorted_azs : regex(local.REGEX_AZ_SHORT, az)[0] => az }
  )


  subnet_inputs = {
    (local.PUBLIC)   = var.public_subnets
    (local.PRIVATE)  = var.private_subnets
    (local.DATABASE) = var.database_subnets
  }

  # Builds the mapper for subnet creation and identifies the active_azs
  # active_az : (AZ's with CIDRs)
  map_subnets = {
    for tier, sub_map in local.subnet_inputs : tier => {
      type       = tier
      subnets    = sub_map
      active_azs = [for az, cidrs in sub_map : local.dict_azs[az] if length(cidrs) > 0]
    }
    if length(sub_map) > 0 # Only include if the variable isn't empty
  }

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # NAT Gateway Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  list_public_active_az_keys = try(local.map_subnets[local.PUBLIC].active_azs, [])

  list_nat_az_keys = !var.enable_nat_gateway ? [] : var.deploy_nat_in_all_public_azs ? local.list_public_active_az_keys : length(var.set_nat_deployment_az_location) == 0 ? try([local.list_public_active_az_keys[0]], []) : [
    for az in var.set_nat_deployment_az_location : local.dict_azs[az]
    if contains(local.list_public_active_az_keys, local.dict_azs[az])
  ]
}



