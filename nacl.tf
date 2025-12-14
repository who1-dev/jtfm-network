module "public_nacls" {
  source = "./sub_modules/nacls"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.vpc.id

  # Submodule-specific Variables
  nacl_type = local.PUB_NACL
  subnets   = module.public_subnets.details
  nacls     = var.nacls_public

  depends_on = [module.public_subnets]
}

module "private_nacls" {
  source = "./sub_modules/nacls"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.vpc.id

  # Submodule-specific Variables
  nacl_type = local.PRV_NACL
  subnets   = module.private_subnets.details
  nacls     = var.nacls_private

  depends_on = [module.private_subnets]
}

module "database_nacls" {
  source = "./sub_modules/nacls"

  # Common Variables
  namespace    = local.namespace
  default_tags = local.default_tags
  vpc_id       = aws_vpc.vpc.id

  # Submodule-specific Variables
  nacl_type = local.DB_NACL
  subnets   = module.database_subnets.details
  nacls     = var.nacls_database

  depends_on = [module.database_subnets]
}