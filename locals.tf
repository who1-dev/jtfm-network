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

  # Builds the mapper for subnet creation and identifies the active_azs
  # active_az : (AZ's with CIDRs)
  map_subnets = {
    for key, value in {
      (local.PUBLIC) = {
        type       = local.PUB_SUB
        subnets    = var.public_subnets
        active_azs = [for az, cidrs in var.public_subnets : local.dict_azs[az] if length(cidrs) > 0]
      }
      (local.PRIVATE) = {
        type       = local.PRV_SUB
        subnets    = var.private_subnets
        active_azs = [for az, cidrs in var.private_subnets : local.dict_azs[az] if length(cidrs) > 0]
      }
      (local.DATABASE) = {
        type       = local.DB_SUB
        subnets    = var.database_subnets
        active_azs = [for az, cidrs in var.database_subnets : local.dict_azs[az] if length(cidrs) > 0]
      }
    } : key => value if length(value.active_azs) > 0
  }


  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # NAT Gateway Related Locals
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  list_public_active_az_keys = try(local.map_subnets[local.PUBLIC].active_azs, [])

  list_nat_az_keys = !var.enable_nat_gateway ? [] : var.deploy_nat_in_all_public_azs ? local.list_public_active_az_keys : length(var.set_nat_deployment_az_location) == 0 ? try([local.list_public_active_az_keys[0]], []) : [
    for az in var.set_nat_deployment_az_location : local.dict_azs[az]
    if contains(local.list_public_active_az_keys, az)
  ]
}



