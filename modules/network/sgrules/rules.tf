resource "aws_security_group_rule" "cidrrules" {
  count = var.create && var.resource_create && length(var.cidr_blocks) > 0 ? length(var.ingress_rules) : 0

  security_group_id = element(var.sg_id, count.index)
  type              = var.type

  cidr_blocks      = var.cidr_blocks
  description      = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}

resource "aws_security_group_rule" "sgrules" {
  count = var.create && var.resource_create && length(var.source_security_group_id) > 0 ? length(var.ingress_rules) : 0

  security_group_id = element(var.sg_id, count.index)
  type              = var.type

  source_security_group_id      = element(concat(var.source_security_group_id, list("")), count.index)
  description      = var.rules[var.ingress_rules[count.index]][3]

  from_port = var.rules[var.ingress_rules[count.index]][0]
  to_port   = var.rules[var.ingress_rules[count.index]][1]
  protocol  = var.rules[var.ingress_rules[count.index]][2]
}