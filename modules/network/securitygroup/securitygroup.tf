resource "aws_security_group" "sg" {
  count = var.create && var.resource_create ? 1 : 0
  description            = var.description
  vpc_id                 = element(var.vpc_id, count.index)
  revoke_rules_on_delete = var.revoke_rules_on_delete
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
      "Environment" = format("%s", var.env)
    },
  )
}