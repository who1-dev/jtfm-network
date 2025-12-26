# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
# NACLS
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
locals {

  // Quarantine NACL should always be created.
  nacls_shared = merge(var.nacls_shared, {
    "quarantine" = {
      name             = "quarantine-nacl"
      is_bidirectional = false
    }
  })

  map_nacls = {
    for key, value in {
      (local.SHARED) = {
        type  = local.SHARED_NACL
        nacls = local.nacls_shared
      }
      (local.PUBLIC) = {
        type  = local.PUB_NACL
        nacls = var.nacls_public
      }
      (local.PRIVATE) = {
        type  = local.PRV_NACL
        nacls = var.nacls_private
      }
      (local.DATABASE) = {
        type  = local.DB_NACL
        nacls = var.nacls_database
      }
    } : key => value if length(value.nacls) > 0
  }
}

module "nacls" {
  source = "./modules/nacls"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.this.id


  # Submodule-specific Variables
  for_each  = local.map_nacls
  nacl_type = each.value.type
  nacls     = each.value.nacls

  depends_on = [module.subnets]
}