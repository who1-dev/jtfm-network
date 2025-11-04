output "mapper" {
  description = "Mapper of created resources"
  value = {
    keys_pub_sub                = local.keys_pub_sub
    flattened_inbound_acl_rules = local.flattened_inbound_acl_rules
    public_inbound_acl_rules    = local.public_inbound_acl_rules

    list_public_az_keys   = local.list_public_az_keys
    list_private_az_keys  = local.list_private_az_keys
    list_database_az_keys = local.list_database_az_keys
    list_nat_az_keys      = local.list_nat_az_keys

    valid_private_nat_az_connections      = local.valid_private_nat_az_connections
    valid_database_nat_az_connections     = local.valid_database_nat_az_connections
    list_private_az_keys_with_nat_access  = local.list_private_az_keys_with_nat_access
    list_database_az_keys_with_nat_access = local.list_database_az_keys_with_nat_access
  }
} 