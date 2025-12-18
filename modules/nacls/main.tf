locals {
  nacl_rules_normalized = {
    for subnet_key, config in var.nacls : subnet_key => {

      # INBOUND: Merge Common Rules (looked up) + Manual Inbound Rules
      inbound = concat(
        # Transform the list of strings ["HTTPS"] into objects
        [for p in config.common_rules : local.NACL_COMMON_RULES[p]],

        # Add the manual rules (defaulting to empty list if null)
        config.inbound_rules == null ? [] : config.inbound_rules
      )

      # OUTBOUND: Handle the Bidirectional Logic specifically for NACLs
      # NACLs are stateless, so "Bidirectional" usually means "Allow Return Traffic" (Ephemeral Ports)
      outbound = concat(
        # 1. If bidirectional, allow Ephemeral Ports (1024-65535) for return traffic
        config.is_bidirectional ? [{
          rule_number = 32766 # High number to avoid conflicts
          protocol    = "tcp"
          rule_action = "allow"
          cidr_block  = "0.0.0.0/0"
          from_port   = 1024
          to_port     = 65535
        }] : [],

        # 2. Add explicit manual outbound rules
        config.outbound_rules == null ? [] : config.outbound_rules
      )
    }
  }

  # ---------------------------------------------------------
  # 2. FLATTENING STAGE (The "Output")
  # Now we just flatten the clean data from above.
  # ---------------------------------------------------------

  # Flatten Inbound
  flattened_inbound_acl_rules = flatten([
    for subnet_key, data in local.nacl_rules_normalized : [
      for idx, rule in data.inbound : {
        # Create a unique key for for_each (e.g., "1B1-100")
        key = "${subnet_key}-IN-${rule.rule_number}"

        nacl_key        = subnet_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = try(rule.cidr_block, null)
        ipv6_cidr_block = try(rule.ipv6_cidr_block, null)
        from_port       = rule.from_port
        to_port         = rule.to_port
        egress          = false
      }
    ]
  ])

  # Flatten Outbound
  flattened_outbound_acl_rules = flatten([
    for subnet_key, data in local.nacl_rules_normalized : [
      for idx, rule in data.outbound : {
        key = "${subnet_key}-OUT-${rule.rule_number}"

        nacl_key        = subnet_key
        rule_number     = rule.rule_number
        protocol        = rule.protocol
        rule_action     = rule.rule_action
        cidr_block      = try(rule.cidr_block, null)
        ipv6_cidr_block = try(rule.ipv6_cidr_block, null)
        from_port       = rule.from_port
        to_port         = rule.to_port
        egress          = true
      }
    ]
  ])
}

resource "aws_network_acl" "this" {
  for_each = toset(keys(var.nacls))
  vpc_id   = var.vpc_id

  tags = merge(var.default_tags, {
    Name = format("%s-%s", var.namespace, var.nacls[each.key].name == null ? var.nacl_type : upper(var.nacls[each.key].name))
  })
}

resource "aws_network_acl_rule" "rules" {
  for_each = { 
    for r in concat(local.flattened_inbound_acl_rules, local.flattened_outbound_acl_rules) : r.key => r 
  }

  network_acl_id = aws_network_acl.this[each.value.nacl_key].id
  
  rule_number    = each.value.rule_number
  egress         = each.value.egress      
  protocol       = each.value.protocol
  rule_action    = each.value.rule_action
  cidr_block     = each.value.cidr_block
  from_port      = each.value.from_port
  to_port        = each.value.to_port

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [ aws_network_acl.this ]
}