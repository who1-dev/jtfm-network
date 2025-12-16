locals {
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # Security Group
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
}
# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.INTERNET_CIDR]
  }
  tags = merge(
    local.default_tags, {
      Name = "${local.namespace}-${each.value.name}"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for idx, rule in local.flattened_security_group_ingress_rules :
    format("%s-%s", rule.ing_key, rule.port) => rule
  }

  security_group_id            = aws_security_group.this[each.value.key].id
  referenced_security_group_id = each.value.referenced_security_group_key != null ? aws_security_group.this[each.value.referenced_security_group_key].id : null
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_block
  description                  = each.value.description

  depends_on = [aws_security_group.this]

  lifecycle {
    create_before_destroy = false
  }
}