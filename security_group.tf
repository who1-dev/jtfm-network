locals {
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  # Security Group
  # ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
  default_internet_rule = {
    port                          = -1
    cidr_block                    = local.INTERNET_CIDR
    referenced_security_group_key = null
    ip_protocol                   = "-1"
    description                   = "Default internet egress"
  }

  security_group_rules = flatten([
    for sg_key, sg_data in var.security_groups : [
      for rule_type in ["ingress", "egress"] : [

        # LOGIC: 
        # Take the list defined in variables (sg_data[rule_type]).
        # If type is "egress" AND enabled, CONCAT the default rule to the end.
        for idx, rule in concat(
          coalesce(sg_data[rule_type], []),
          (rule_type == "egress" && sg_data.enable_default_egress ? [local.default_internet_rule] : [])
          ) : merge(rule, {
            type       = rule_type
            sg_key     = sg_key
            unique_key = "${sg_key}-${rule_type}-${idx}-${rule.port}"
        })
      ]
    ]
  ])
}


# ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.this.id

  tags = merge(
    local.default_tags, {
      Name = "${local.namespace}-${each.value.name}"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "custom" {
  # FILTER: Only grab rules where type == "ingress"
  for_each = {
    for r in local.security_group_rules : r.unique_key => r
    if r.type == "ingress"
  }

  security_group_id            = aws_security_group.this[each.value.sg_key].id
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

resource "aws_vpc_security_group_egress_rule" "custom" {
  # FILTER: Only grab rules where type == "egress"
  for_each = {
    for r in local.security_group_rules : r.unique_key => r
    if r.type == "egress"
  }

  security_group_id            = aws_security_group.this[each.value.sg_key].id
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