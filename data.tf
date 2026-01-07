data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_role" "vpc_flow_log" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = var.ds_vpc_flow_log_role_name
}