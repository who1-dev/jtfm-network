locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "environment" : var.env }

  # Constant Naming conventions:
  VPC         = "vpc"
  IGW         = "igw"
  NATGW       = "natgw"
  EIP         = "eip"
  PUB_NACL    = "pub-nacl"
  PRV_NACL    = "prv-nacl"
  DB_NACL     = "db-nacl"
  SHARED_NACL = "shared-nacl"

  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # WARNING!!! : Changing values below will force recreation of SUBNET and NACL associations
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  #Resource Keys
  SHARED   = "shared"
  PUBLIC   = "public"
  PRIVATE  = "private"
  DATABASE = "database"

  VPC_ENDPOINT_SERVICES = {
    ECR            = ["ecr.api", "ecr.dkr"]
    ECS            = ["ecs", "ecs-agent", "ecs-telemetry"]
    SECRETSMANAGER = ["secretsmanager"]
    SSM            = ["ssm", "ssmmessages", "ec2messages"]
  }
}


