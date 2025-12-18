locals {
  # Constants:
  INTERNET_CIDR      = "0.0.0.0/0"
  INTERNET_CIDR_IPV6 = "::/0"

  REGEX_AZ_SHORT = "([0-9]+[a-z])"
  default_tags   = { "Environment" : upper(var.env) }

  # Constant Naming conventions:
  VPC         = "VPC"
  IGW         = "IGW"
  NATGW       = "NATGW"
  EIP         = "EIP"
  PRV_SUB     = "PRVSUB"
  PUB_SUB     = "PUBSUB"
  DB_SUB      = "DBSUB"
  RT_ASSOC    = "RTASSOC"
  PUB_NACL    = "PUB-NACL"
  PRV_NACL    = "PRV-NACL"
  DB_NACL     = "DB-NACL"
  SHARED_NACL = "SHARED-NACL"


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


