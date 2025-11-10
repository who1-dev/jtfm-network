output "mapper" {
  description = "Mapper of created resources"
  value = {
    list_private_az_keys = local.list_private_az_keys
    # list_az_keys       = local.list_az_keys
    # map_public_subnets = local.map_public_subnets
    # valid_private_keys = local.valid_private_keys

    # list_public_az_keys   = local.list_public_az_keys
    # list_private_az_keys  = local.list_private_az_keys
    # list_database_az_keys = local.list_database_az_keys
    # list_nat_az_keys      = local.list_nat_az_keys

    # valid_private_nat_az_connections      = local.valid_private_nat_az_connections
    # valid_database_nat_az_connections     = local.valid_database_nat_az_connections
    # list_private_az_keys_with_nat_access  = local.list_private_az_keys_with_nat_access
    # list_database_az_keys_with_nat_access = local.list_database_az_keys_with_nat_access
  }
} 