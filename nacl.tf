# Create Public Network ACL
resource "aws_network_acl" "public" {
  for_each = toset(var.public_acls)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_NACL)
  })

  depends_on = [aws_subnet.public]

}

resource "aws_network_acl_association" "public" {
  for_each       = toset(var.public_acls)
  network_acl_id = aws_network_acl.public[each.key].id
  subnet_id      = aws_subnet.public[each.key].id

  depends_on = [aws_network_acl.public]
}


resource "aws_network_acl_rule" "public_inbound" {
  for_each = {
    for idx, rule in local.flattened_public_inbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.public[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = false
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.public]
}

resource "aws_network_acl_rule" "public_outbound" {
  for_each = {
    for idx, rule in local.flattened_public_outbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.public[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = true
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.public]
}

# Create private Network ACL
resource "aws_network_acl" "private" {
  for_each = toset(var.private_acls)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_NACL)
  })

  depends_on = [aws_subnet.private]

}

resource "aws_network_acl_association" "private" {
  for_each       = toset(var.private_acls)
  network_acl_id = aws_network_acl.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id

  depends_on = [aws_network_acl.private]
}


resource "aws_network_acl_rule" "private_inbound" {
  for_each = {
    for idx, rule in local.flattened_private_inbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.private[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = false
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.private]
}

resource "aws_network_acl_rule" "private_outbound" {
  for_each = {
    for idx, rule in local.flattened_private_outbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.private[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = true
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.private]
}

# Create database Network ACL
resource "aws_network_acl" "database" {
  for_each = toset(var.database_acls)
  vpc_id   = aws_vpc.vpc.id

  tags = merge(local.default_tags, {
    Name = format("%s-%s", local.namespace, local.PUB_NACL)
  })

  depends_on = [aws_subnet.database]

}

resource "aws_network_acl_association" "database" {
  for_each       = toset(var.database_acls)
  network_acl_id = aws_network_acl.database[each.key].id
  subnet_id      = aws_subnet.database[each.key].id

  depends_on = [aws_network_acl.database]
}


resource "aws_network_acl_rule" "database_inbound" {
  for_each = {
    for idx, rule in local.flattened_database_inbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.database[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = false
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.database]
}

resource "aws_network_acl_rule" "database_outbound" {
  for_each = {
    for idx, rule in local.flattened_database_outbound_acl_rules :
    "${rule.acl_key}-${rule.rule_number}" => rule
  }

  network_acl_id  = aws_network_acl.database[each.value.acl_key].id
  rule_number     = each.value.rule_number
  egress          = true
  protocol        = each.value.protocol
  rule_action     = each.value.rule_action
  cidr_block      = lookup(each.value, "cidr_block", null)
  ipv6_cidr_block = lookup(each.value, "ipv6_cidr_block", null)
  from_port       = each.value.from_port
  to_port         = each.value.to_port

  depends_on = [aws_network_acl_association.database]
}